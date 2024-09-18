import 'package:flutter/material.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:url_launcher/url_launcher.dart';

void mostrarModalInfoMascota(BuildContext context, Mascota mascota) {
  int currentImageIndex = 0; // Inicializamos el índice aquí

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Determinar si la pantalla es lo suficientemente grande para un diseño horizontal
                bool isLargeScreen = constraints.maxWidth > 600;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: isLargeScreen
                      ? Row( // Diseño horizontal
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen a la izquierda
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente la imagen
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back),
                                        iconSize: 30.0,
                                        onPressed: () {
                                          if (mascota.fotos.isNotEmpty) {
                                            setState(() {
                                              if (currentImageIndex > 0) {
                                                currentImageIndex--;
                                              } else {
                                                currentImageIndex = mascota.fotos.length - 1;
                                              }
                                            });
                                          }
                                        },
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 60.0), // Añade un padding para bajar la imagen
                                          child: mascota.fotos.isNotEmpty
                                              ? Image.asset(
                                                  'assets/imagenes/fotos_mascotas/${mascota.fotos[currentImageIndex]}',
                                                  width: 400,
                                                  height: 400,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(Icons.error, size: 200, color: Colors.red);
                                                  },
                                                )
                                              : Icon(Icons.pets, size: 200, color: Colors.grey),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward),
                                        iconSize: 30.0,
                                        onPressed: () {
                                          if (mascota.fotos.isNotEmpty) {
                                            setState(() {
                                              if (currentImageIndex < mascota.fotos.length - 1) {
                                                currentImageIndex++;
                                              } else {
                                                currentImageIndex = 0;
                                              }
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20), // Separador entre imagen y detalles
                            // Detalles de la mascota y del dueño a la derecha
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoCard('Información de la Mascota', [
                                    _buildInfoText('Nombre', mascota.nombre),
                                    _buildInfoText('${mascota.especie} - ${mascota.raza}', ''),
                                    _buildInfoText('Sexo', mascota.sexo),
                                    _buildInfoText('Fecha Perdida', mascota.fechaPerdida),
                                    _buildInfoText('Lugar Perdida', mascota.lugarPerdida),
                                    _buildInfoText('Estado', mascota.estado),
                                    _buildInfoText('Descripción', mascota.descripcion),
                                  ]),
                                  SizedBox(height: 16),
                                  _buildInfoCard('Información del Dueño', [
                                    _buildInfoText('Nombre', mascota.nombreDueno),
                                    _buildInteractiveText('Email', mascota.emailDueno, 'mailto:${mascota.emailDueno}'),
                                    _buildPhoneRow('Teléfono', mascota.telefonoDueno),
                                  ]),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Cerrar el modal
                                    },
                                    child: Text('Cerrar'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column( // Diseño vertical para pantallas pequeñas
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (mascota.estado == 'encontrado')
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '¡Mascota reunida con su familia!',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            if (mascota.estado == 'perdido')
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 206, 71, 71),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '¡Hay una familia que busca a esta mascota!',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  iconSize: 30.0,
                                  onPressed: () {
                                    if (mascota.fotos.isNotEmpty) {
                                      setState(() {
                                        if (currentImageIndex > 0) {
                                          currentImageIndex--;
                                        } else {
                                          currentImageIndex = mascota.fotos.length - 1;
                                        }
                                      });
                                    }
                                  },
                                ),
                                Expanded(
                                  child: mascota.fotos.isNotEmpty
                                      ? Image.asset(
                                          'assets/imagenes/fotos_mascotas/${mascota.fotos[currentImageIndex]}',
                                          width: 400,
                                          height: 400,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Icon(Icons.error, size: 200, color: Colors.red);
                                          },
                                        )
                                      : Icon(Icons.pets, size: 200, color: Colors.grey),
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  iconSize: 30.0,
                                  onPressed: () {
                                    if (mascota.fotos.isNotEmpty) {
                                      setState(() {
                                        if (currentImageIndex < mascota.fotos.length - 1) {
                                          currentImageIndex++;
                                        } else {
                                          currentImageIndex = 0;
                                        }
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            _buildInfoCard('Información de la Mascota', [
                              _buildInfoText('Nombre', mascota.nombre),
                              _buildInfoText('${mascota.especie} - ${mascota.raza}', ''),
                              _buildInfoText('Sexo', mascota.sexo),
                              _buildInfoText('Fecha Perdida', mascota.fechaPerdida),
                              _buildInfoText('Lugar Perdida', mascota.lugarPerdida),
                              _buildInfoText('Estado', mascota.estado),
                              _buildInfoText('Descripción', mascota.descripcion),
                            ]),
                            SizedBox(height: 16),
                            _buildInfoCard('Información del Dueño', [
                              _buildInfoText('Nombre', mascota.nombreDueno),
                              _buildInteractiveText('Email', mascota.emailDueno, 'mailto:${mascota.emailDueno}'),
                              _buildPhoneRow('Teléfono', mascota.telefonoDueno),
                            ]),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Cerrar el modal
                              },
                              child: Text('Cerrar'),
                            ),
                          ],
                        ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: 500,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Divider(),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveText(String label, String value, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'No se pudo iniciar $url';
                }
              },
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String label, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    final telUri = Uri.parse('tel:$phoneNumber');
                    if (await canLaunchUrl(telUri)) {
                      await launchUrl(telUri);
                    } else {
                      throw 'No se pudo iniciar $telUri';
                    }
                  },
                  child: Text(
                    phoneNumber,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
                    if (await canLaunchUrl(whatsappUri)) {
                      await launchUrl(whatsappUri);
                    } else {
                      throw 'No se pudo iniciar $whatsappUri';
                    }
                  },
                  child: Image.asset(
                    '../../../assets/imagenes/whatsapp.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }