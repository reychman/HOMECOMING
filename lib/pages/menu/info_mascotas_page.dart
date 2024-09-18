import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homecoming/pages/mascota.dart';

class InfoMascotasPage extends StatefulWidget {
  final Mascota mascota;

  InfoMascotasPage({required this.mascota});

  @override
  _InfoMascotasPageState createState() => _InfoMascotasPageState();
}

class _InfoMascotasPageState extends State<InfoMascotasPage> {
  // Variable para almacenar el índice actual de la imagen
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mascota = widget.mascota; // Acceder a la mascota desde widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Mascota: ${mascota.nombre}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (mascota.estado == 'encontrado')
              Container(
                width: 400,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '¡Mascota reunida con su familia!',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            if (mascota.estado == 'perdido')
              Container(
                width: 400,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 206, 71, 71),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Text(
                  '¡Hay una familia que busca a esta mascota!',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 16),
            // Contenedor de la imagen con flechas de navegación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botón de imagen anterior
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 30.0,
                  onPressed: () {
                    if (mascota.fotos.isNotEmpty) {
                      setState(() {
                        // Navegar a la imagen anterior
                        if (_currentImageIndex > 0) {
                          _currentImageIndex--;
                        } else {
                          _currentImageIndex = mascota.fotos.length - 1; // Ir a la última imagen si estamos en la primera
                        }
                      });
                    }
                  },
                ),
                Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        // Aquí puedes agregar alguna funcionalidad si es necesario
                      },
                      child: mascota.fotos.isNotEmpty
                          ? Image.asset(
                              'assets/imagenes/fotos_mascotas/${mascota.fotos[_currentImageIndex]}',
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
                ),
                // Botón de imagen siguiente
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  iconSize: 30.0,
                  onPressed: () {
                    if (mascota.fotos.isNotEmpty) {
                      setState(() {
                        // Navegar a la siguiente imagen
                        if (_currentImageIndex < mascota.fotos.length - 1) {
                          _currentImageIndex++;
                        } else {
                          _currentImageIndex = 0; // Volver a la primera imagen si estamos en la última
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return SizedBox(
      width: 500, // Ajusta el ancho deseado aquí
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
}
