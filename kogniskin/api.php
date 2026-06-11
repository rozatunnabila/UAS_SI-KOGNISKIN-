<?php
// api.php - KogniSkin API
// Update: support photo_url di reviews (base64) dan image_url di products

require_once 'config.php';

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$request_uri = $_SERVER['REQUEST_URI'];
$method = $_SERVER['REQUEST_METHOD'];

$path = str_replace('/kogniskin/api.php', '', parse_url($request_uri, PHP_URL_PATH));
$path = trim($path, '/');
$segments = explode('/', $path);

$response = ['success' => false, 'message' => 'Invalid request'];

try {
    switch ($method) {
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            // ===== LOGIN =====
            if ($segments[0] === 'login') {
                $email    = $input['email']    ?? '';
                $password = md5($input['password'] ?? '');
                
                $stmt = $pdo->prepare("SELECT * FROM users WHERE (email = ? OR username = ?) AND password = ?");
                $stmt->execute([$email, $email, $password]);
                $user = $stmt->fetch();
                
                if ($user) {
                    unset($user['password']);
                    $response = ['success' => true, 'user' => $user];
                } else {
                    $response = ['success' => false, 'message' => 'Email/Username atau password salah'];
                }
            }
            
            // ===== REGISTER =====
            elseif ($segments[0] === 'register') {
                $username = $input['username'] ?? '';
                $email    = $input['email']    ?? '';
                $password = md5($input['password'] ?? '');
                
                $stmt = $pdo->prepare("SELECT id FROM users WHERE username = ? OR email = ?");
                $stmt->execute([$username, $email]);
                if ($stmt->fetch()) {
                    $response = ['success' => false, 'message' => 'Username atau email sudah terdaftar'];
                } else {
                    $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
                    $stmt->execute([$username, $email, $password]);
                    $user_id = $pdo->lastInsertId();
                    
                    $stmt = $pdo->prepare("SELECT id, username, email, skin_type, issues, join_date FROM users WHERE id = ?");
                    $stmt->execute([$user_id]);
                    $user = $stmt->fetch();
                    $response = ['success' => true, 'user' => $user];
                }
            }
            
            // ===== UPDATE SKIN =====
            elseif ($segments[0] === 'update_skin' && isset($segments[1])) {
                $user_id   = $segments[1];
                $skin_type = $input['skin_type'] ?? '';
                $issues    = is_array($input['issues']) ? implode(',', $input['issues']) : $input['issues'];
                $quiz_date = date('Y-m-d');
                
                $stmt = $pdo->prepare("UPDATE users SET skin_type = ?, issues = ?, skin_quiz_date = ? WHERE id = ?");
                $stmt->execute([$skin_type, $issues, $quiz_date, $user_id]);
                $response = ['success' => true];
            }
            
            // ===== ADD REVIEW (DENGAN FOTO) =====
            elseif ($segments[0] === 'add_review') {
                // photo_url bisa berupa:
                // - string base64 (data:image/jpeg;base64,...)
                // - URL eksternal
                // - null (tidak ada foto)
                $photo_url = isset($input['photo_url']) && !empty($input['photo_url'])
                    ? $input['photo_url']
                    : null;
                
                // Validasi: pastikan base64 yang dikirim valid
                if ($photo_url !== null && strpos($photo_url, 'data:image') === 0) {
                    // Cek ukuran data base64 (maks ~5MB setelah encode = ~6.7MB string)
                    if (strlen($photo_url) > 7 * 1024 * 1024) {
                        $response = ['success' => false, 'message' => 'Ukuran foto terlalu besar (maks 5MB)'];
                        break;
                    }
                }
                
                $stmt = $pdo->prepare("
                    INSERT INTO reviews
                        (user_id, username, avatar, skin_type, issues, product_id, product_name, rating, review_text, review_date, photo_url)
                    VALUES
                        (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE(), ?)
                ");
                $stmt->execute([
                    $input['user_id'],
                    $input['username'],
                    $input['avatar']       ?? '#C4785A',
                    $input['skin_type']    ?? null,
                    $input['issues']       ?? null,
                    $input['product_id'],
                    $input['product_name'] ?? null,
                    $input['rating'],
                    $input['review_text'],
                    $photo_url
                ]);
                $response = ['success' => true, 'review_id' => $pdo->lastInsertId()];
            }
            break;
            
        case 'GET':
            // ===== GET USER =====
            if ($segments[0] === 'user' && isset($segments[1])) {
                $stmt = $pdo->prepare("SELECT id, username, email, skin_type, issues, skin_quiz_date, join_date FROM users WHERE id = ?");
                $stmt->execute([$segments[1]]);
                $user = $stmt->fetch();
                if ($user) {
                    $user['issues'] = $user['issues'] ? explode(',', $user['issues']) : [];
                    $response = ['success' => true, 'user' => $user];
                } else {
                    $response = ['success' => false, 'message' => 'User not found'];
                }
            }
            
            // ===== GET REVIEWS (DENGAN FOTO) =====
            elseif ($segments[0] === 'reviews') {
                $stmt = $pdo->prepare("SELECT * FROM reviews ORDER BY created_at DESC");
                $stmt->execute();
                $reviews = $stmt->fetchAll();
                foreach ($reviews as &$review) {
                    $review['issues'] = $review['issues'] ? explode(',', $review['issues']) : [];
                    // photo_url sudah di-return langsung dari database (base64 atau URL)
                }
                $response = ['success' => true, 'reviews' => $reviews];
            }
            
            // ===== GET PRODUCTS (DENGAN IMAGE_URL) =====
            elseif ($segments[0] === 'products') {
                $stmt = $pdo->prepare("SELECT * FROM products ORDER BY rating DESC");
                $stmt->execute();
                $products = $stmt->fetchAll();
                // image_url sudah di-return langsung
                $response = ['success' => true, 'products' => $products];
            }
            
            // ===== GET STATS =====
            elseif ($segments[0] === 'skin_stats') {
                $stmt = $pdo->prepare("SELECT * FROM skin_data");
                $stmt->execute();
                $response = ['success' => true, 'skin_stats' => $stmt->fetchAll()];
            }
            
            elseif ($segments[0] === 'total_users') {
                $stmt = $pdo->prepare("SELECT COUNT(*) as total FROM users");
                $stmt->execute();
                $total = $stmt->fetch();
                $response = ['success' => true, 'total_users' => $total['total']];
            }
            
            // ===== RECOMMENDATIONS =====
            elseif ($segments[0] === 'recommendations' && isset($segments[1]) && isset($segments[2])) {
                $skin_type  = urldecode($segments[1]);
                $issues     = urldecode($segments[2]);
                $issue_array = explode(',', $issues);
                
                $ingredient_mapping = [
                    'Kulit Berminyak' => [
                        'Jerawat'   => ['Niacinamide','Salicylic Acid','Tea Tree Oil','Zinc PCA'],
                        'Pori Besar'=> ['Niacinamide','Witch Hazel'],
                        'Komedo'    => ['Salicylic Acid','Niacinamide'],
                        'Berminyak' => ['Niacinamide','Zinc PCA','Salicylic Acid']
                    ],
                    'Kulit Kering' => [
                        'Dehidrasi' => ['Hyaluronic Acid','Glycerin','Squalane'],
                        'Kusam'     => ['Hyaluronic Acid','Vitamin C'],
                        'Iritasi'   => ['Ceramide','Centella Asiatica','Panthenol']
                    ],
                    'Kulit Kombinasi' => [
                        'Jerawat'   => ['Niacinamide','Salicylic Acid'],
                        'Pori Besar'=> ['Niacinamide','Witch Hazel'],
                        'Kusam'     => ['AHA','Niacinamide','Vitamin C']
                    ],
                    'Kulit Sensitif' => [
                        'Kemerahan' => ['Centella Asiatica','Aloe Vera','Ceramide'],
                        'Iritasi'   => ['Centella Asiatica','Ceramide','Panthenol']
                    ],
                    'Kulit Normal' => [
                        'Kusam'   => ['Vitamin C','AHA','Hyaluronic Acid'],
                        'Keriput' => ['Retinol','Peptide','Bakuchiol']
                    ]
                ];
                
                $recommended_ingredients = [];
                foreach ($issue_array as $issue) {
                    $issue_trim = trim($issue);
                    if (isset($ingredient_mapping[$skin_type][$issue_trim])) {
                        $recommended_ingredients = array_merge(
                            $recommended_ingredients,
                            $ingredient_mapping[$skin_type][$issue_trim]
                        );
                    }
                }
                $recommended_ingredients = array_unique($recommended_ingredients);
                
                if (empty($recommended_ingredients)) {
                    $default_mapping = [
                        'Kulit Berminyak' => ['Niacinamide','Salicylic Acid'],
                        'Kulit Kering'    => ['Hyaluronic Acid','Ceramide'],
                        'Kulit Kombinasi' => ['Niacinamide','Hyaluronic Acid'],
                        'Kulit Sensitif'  => ['Centella Asiatica','Ceramide'],
                        'Kulit Normal'    => ['Vitamin C','Hyaluronic Acid']
                    ];
                    $recommended_ingredients = $default_mapping[$skin_type] ?? ['Niacinamide','Hyaluronic Acid'];
                }
                
                $placeholders = implode(',', array_fill(0, count($recommended_ingredients), '?'));
                $sql = "
                    SELECT p.*,
                        COUNT(DISTINCT i.id) as matching_ingredients,
                        GROUP_CONCAT(DISTINCT i.name) as matched_ingredients
                    FROM products p
                    JOIN product_ingredients pi ON p.id = pi.product_id
                    JOIN ingredients i ON pi.ingredient_id = i.id
                    WHERE i.name IN ($placeholders)
                    GROUP BY p.id
                    ORDER BY matching_ingredients DESC, p.rating DESC
                    LIMIT 10
                ";
                
                $stmt = $pdo->prepare($sql);
                $stmt->execute($recommended_ingredients);
                $products = $stmt->fetchAll();
                
                foreach ($products as &$product) {
                    $matched     = explode(',', $product['matched_ingredients']);
                    $match_count = count($matched);
                    $total_exp   = count($recommended_ingredients);
                    $product['calculated_match'] = $total_exp > 0
                        ? round(($match_count / $total_exp) * 100)
                        : 80;
                }
                
                $response = [
                    'success'                  => true,
                    'recommended_ingredients'  => $recommended_ingredients,
                    'products'                 => $products,
                    'skin_type'                => $skin_type,
                    'issues'                   => $issue_array
                ];
            }
            break;
            
        default:
            $response = ['success' => false, 'message' => 'Method not allowed'];
    }
} catch(Exception $e) {
    $response = ['success' => false, 'message' => 'Server error: ' . $e->getMessage()];
}

echo json_encode($response);
?>