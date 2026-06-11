from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
import tensorflow as tf
import numpy as np
from PIL import Image
import io

app = FastAPI()

# Mengizinkan index.html mengakses API ini (CORS)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load model AI
# Kode baru agar langsung membaca file di folder yang sama
model = tf.keras.models.load_model('model_kulit.h5')

# PENTING: Urutannya harus sama persis dengan hasil print dari train.py!
# Contoh jika urutannya: Berminyak, Kering, Normal
LABELS = ['Kulit Berminyak', 'Kulit Kering', 'Kulit Normal']

@app.post("/predict")
async def predict_skin(file: UploadFile = File(...)):
    # Baca file gambar
    contents = await file.read()
    image = Image.open(io.BytesIO(contents)).convert("RGB")
    
    # Preprocessing
    image = image.resize((224, 224))
    img_array = np.array(image) / 255.0
    img_array = np.expand_dims(img_array, axis=0)
    
    # Prediksi AI
    preds = model.predict(img_array)
    highest_idx = np.argmax(preds[0])
    
    return {
        "userSkinType": LABELS[highest_idx],
        "confidence": float(preds[0][highest_idx])
    }