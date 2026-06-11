import tensorflow as tf
# Di TensorFlow terbaru, keras langsung diakses dari objek tf
ImageDataGenerator = tf.keras.preprocessing.image.ImageDataGenerator
MobileNetV2 = tf.keras.applications.MobileNetV2
Dense = tf.keras.layers.Dense
GlobalAveragePooling2D = tf.keras.layers.GlobalAveragePooling2D
Model = tf.keras.models.Model

# Setup path dataset
train_dir = 'train'
val_dir = 'valid'

train_datagen = ImageDataGenerator(rescale=1./255, rotation_range=20, horizontal_flip=True)
val_datagen = ImageDataGenerator(rescale=1./255)

train_generator = train_datagen.flow_from_directory(
    train_dir, target_size=(224, 224), batch_size=32, class_mode='categorical')

val_generator = val_datagen.flow_from_directory(
    val_dir, target_size=(224, 224), batch_size=32, class_mode='categorical')

# Cetak urutan label biar tidak tertukar di app.py nanti
print("Urutan Kelas:", train_generator.class_indices)

# Buat model lewat Transfer Learning
base_model = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base_model.trainable = False 

x = base_model.output
x = GlobalAveragePooling2D()(x)
x = Dense(128, activation='relu')(x)
# Sesuaikan angka 3 dengan jumlah kategori jenis kulit di datasetmu
predictions = Dense(3, activation='softmax')(x) 

model = Model(inputs=base_model.input, outputs=predictions)
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Mulai Training
model.fit(train_generator, validation_data=val_generator, epochs=5)

# Simpan hasilnya
model.save('model_kulit.h5')
print("Selesai! File model_kulit.h5 telah dibuat.")