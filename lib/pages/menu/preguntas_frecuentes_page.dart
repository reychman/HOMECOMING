import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:url_launcher/url_launcher.dart';

class PreguntasFrecuentesPage extends StatefulWidget {
  @override
  _PreguntasFrecuentesPageState createState() => _PreguntasFrecuentesPageState();
}

class _PreguntasFrecuentesPageState extends State<PreguntasFrecuentesPage> {
  Usuario? usuario;

  String tituloGeneral = 'Consejos de qué hacer si encuentras un perro perdido';
  String tituloActual = 'Encontré un perro perdido ... ¿qué debo hacer?';
  String contenidoActual =
      'Si encuentras un perro perdido, es importante mantener la calma y seguir estos pasos:\n\n'
      '1. Verifica si el perro tiene collar o placa de identificación.\n'
      '2. Si puedes acercarte de manera segura, revisa si tiene un microchip (puedes llevarlo a cualquier veterinaria).\n'
      '3. Toma fotos del perro y compártelas en redes sociales locales.\n'
      '4. Contacta con las protectoras de animales de tu zona.\n'
      '5. Si puedes, ofrécele agua y comida mientras buscas a su familia.\n'
      '6. Crea carteles y colócalos en la zona donde lo encontraste.\n\n'
      'Recuerda que tu ayuda puede ser crucial para reunir a una familia con su mascota perdida.';
  String imagenActual = 'http://$serverIP/homecoming/assets/imagenes/perro_perdido.jpg';
  bool mostrarPlantillas = false;

  void actualizarContenido(String nuevoTituloGeneral, String nuevoTitulo,
      String nuevoContenido, String nuevaImagen,
      {bool plantillas = false}) {
    setState(() {
      tituloGeneral = nuevoTituloGeneral;
      tituloActual = nuevoTitulo;
      contenidoActual = nuevoContenido;
      imagenActual = nuevaImagen;
      mostrarPlantillas = plantillas;
    });
  }

  Future<void> descargarPlantilla(String numeroPlantilla) async {
    final url = 'http://$serverIP/homecoming/assets/plantillas/plantilla_$numeroPlantilla.docx';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas Frecuentes'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      backgroundColor: Colors.green[50],
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 768) {
              // Mobile layout
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPopularPostsMenu(),
                    SizedBox(height: 16),
                    _buildContentCard(),
                  ],
                ),
              );
            } else {
              // Desktop layout
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildPopularPostsMenu(),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: _buildContentCard(),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
    Widget _buildContentCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tituloGeneral,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagenActual,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(Icons.error_outline, size: 40),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Text(
              tituloActual,
              style: TextStyle(
                fontSize: 18,
                color: Colors.orange[800],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              contenidoActual,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.left,
            ),
            if (mostrarPlantillas) ...[
              SizedBox(height: 24),
              Text(
                'Descarga Plantillas de Carteles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 16),
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ElevatedButton.icon(
                  icon: Icon(Icons.download),
                  label: Text('Plantilla ${index + 1}'),
                  style: ElevatedButton.styleFrom(
                    iconColor: Colors.green[600],
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => descargarPlantilla('${index + 1}'),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildPopularPostsMenu() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Publicaciones Populares',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[700],
              ),
            ),
            Divider(thickness: 2),
            _buildMenuItem(
              'Consejos de qué hacer si encuentras un perro perdido',
              Icons.pets,
              () => actualizarContenido(
                'Consejos de qué hacer si encuentras un perro perdido',
                '¿Qué hacer cuando encuentras un perro perdido?',
                'Si encuentras un perro perdido, es importante mantener la calma y seguir estos pasos:\n\n'
                '1. Verifica si el perro tiene collar o placa de identificación.\n'
                '2. Si puedes acercarte de manera segura, revisa si tiene un microchip.\n'
                '3. Toma fotos del perro y compártelas en redes sociales locales.\n'
                '4. Contacta con las protectoras de animales de tu zona.\n'
                '5. Si puedes, ofrécele agua y comida mientras buscas a su familia.\n'
                '6. Crea carteles y colócalos en la zona donde lo encontraste.',
                'http://$serverIP/homecoming/assets/imagenes/perro_perdido.jpg',
              ),
            ),
            _buildMenuItem(
              'Oración a San Roque para encontrar un perro',
              Icons.favorite,
              () => actualizarContenido(
                'Oración a San Roque para encontrar un perro',
                'Oración a San Roque, patrono de los perros',
                'Oh Dios misericordiosísimo, que por medio de un ángel prometiste a San Roque que quien invocase su nombre sería preservado de pestes y enfermedades contagiosas, concédenos que por su intercesión seamos preservados de todos los peligros, tanto del alma como del cuerpo, por Jesucristo nuestro Señor. Amén.\n\n' 
                'Oración para pedir humildad:\n'
                'Oh glorioso San Roque, que por vuestro ardiente amor a Jesús habéis abandonado riquezas y honores y buscasteis la humillación, enseñadme a ser humilde ante Dios y los hombres.\n\n' 
                'Oración para pedir sanación:\n'
                'Amado San Roque, con tu poder sanador, te pido que cures mi cuerpo, mi mente y mi alma, devolviéndome la paz y el amor necesarios para seguir con mis días.\n\n'
                'Oración para pedir salud para las mascotas:\n'
                'San Roque, protector de los enfermos, intercede por nosotros ante el Señor para que nos conceda salud y fortaleza en cuerpo y alma. Amén.\n\n\n' 
                'San Roque es el santo protector contra la peste y las epidemias.\nSu onomástica es el 16 de agosto.',
                'http://$serverIP/homecoming/assets/imagenes/oracion_san_roque.jpg',
              ),
            ),
            _buildMenuItem(
              'Campaña "Un tarro de agua para los perritos de la calle"',
              Icons.water_drop,
              () => actualizarContenido(
                'Campaña "Un tarro de agua para los perritos de la calle"',
                'Ayuda a los perritos de la calle con agua fresca',
                'La campaña "Un tarro de agua para los perritos de la calle" es una iniciativa que busca '
                'ayudar a los perros callejeros durante los días calurosos. Consiste en colocar recipientes '
                'con agua fresca en lugares seguros de la calle.\n\n'
                'Consejos para participar:\n'
                '• Usa recipientes bajos y estables\n'
                '• Colócalos en lugares con sombra\n'
                '• Cambia el agua diariamente\n'
                '• Mantén los recipientes limpios\n'
                '• Evita lugares peligrosos para los perros',
                'http://$serverIP/homecoming/assets/imagenes/campana_agua.jpg',
              ),
            ),
            _buildMenuItem(
              '¿Qué distancia recorre un perro perdido?',
              Icons.map,
              () => actualizarContenido(
                '¿Qué distancia recorre un perro perdido?',
                'Distancias que puede recorrer un perro perdido',
                'Los perros perdidos pueden recorrer distancias sorprendentes. En promedio:\n\n'
                '• Perros pequeños: 2-3 km por día\n'
                '• Perros medianos: 5-10 km por día\n'
                '• Perros grandes: Hasta 15 km por día\n\n'
                'Factores que influyen:\n'
                '• Temperamento del perro\n'
                '• Clima y terreno\n'
                '• Disponibilidad de comida y agua\n'
                '• Nivel de miedo o estrés\n\n'
                'Por esto es importante ampliar el área de búsqueda gradualmente y no limitarse solo al '
                'vecindario inmediato.',
                'http://$serverIP/homecoming/assets/imagenes/distancia_perro.jpg',
              ),
            ),
            _buildMenuItem(
              '¿Cómo encontrar un perro robado?',
              Icons.search,
              () => actualizarContenido(
                '¿Cómo encontrar un perro robado?',
                'Pasos para encontrar un perro robado',
                'Si sospechas que tu perro ha sido robado, sigue estos pasos:\n\n'
                '1. Denuncia inmediatamente a la policía\n'
                '2. Contacta con todas las veterinarias de la zona\n'
                '3. Revisa sitios de venta de mascotas online\n'
                '4. Publica en redes sociales con fotos claras\n'
                '5. Coloca carteles en la zona\n'
                '6. Contacta con protectoras y refugios\n'
                '7. Ofrece una recompensa si es posible\n\n'
                'Mantén siempre la documentación de tu mascota actualizada y considera ponerle un microchip.',
                'http://$serverIP/homecoming/assets/imagenes/perro_robado.jpg',
              ),
            ),
            _buildMenuItem(
              '¿Cómo hacer un cartel de se busca perro?',
              Icons.description,
              () => actualizarContenido(
                '¿Cómo hacer un cartel de se busca perro?',
                'Guía para crear un cartel efectivo de perro perdido',
                'Un cartel efectivo de "Se Busca" es crucial para encontrar a tu mascota perdida. '
                'Elementos esenciales que debe incluir:\n\n'
                '1. FOTO CLARA Y RECIENTE de tu mascota\n'
                '2. La palabra "PERDIDO" o "SE BUSCA" en letras grandes\n'
                '3. Nombre del perro\n'
                '4. Raza y características distintivas\n'
                '5. Lugar y fecha donde se perdió\n'
                '6. Número de contacto\n'
                '7. Si ofreces recompensa\n\n'
                'Hemos preparado tres plantillas profesionales que puedes descargar y personalizar '
                'gratuitamente. Cada plantilla está diseñada para maximizar la visibilidad y '
                'proporcionar toda la información necesaria de manera clara y efectiva.\n\n'
                'Consejos adicionales:\n'
                '• Usa papel resistente al agua\n'
                '• Coloca los carteles a la altura de los ojos\n'
                '• Distribuye en un radio amplio\n'
                '• Actualiza o retira los carteles cuando sea necesario',
                'http://$serverIP/homecoming/assets/imagenes/cartel_busqueda.jpg',
                plantillas: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap) {
      return ListTile(
        leading: Icon(icon, color: Colors.green[700]),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        tileColor: Colors.green[50],
        hoverColor: Colors.green[100],
      );
    }
  }