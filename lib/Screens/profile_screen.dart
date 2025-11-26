import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold( // Cambiado a Scaffold para mejor manejo de layout
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          // 1. HEADER EMPRESARIAL
          const _BusinessHeader(),
          const SizedBox(height: 24),

          // 2. TARJETA FINANCIERA (CRÉDITO KUSKA) - ¡Alto Valor B2B!
          const _CreditLineCard(),
          const SizedBox(height: 20),

          // 3. DASHBOARD DE IMPACTO (S³) - Justificación de valor
          const _ImpactDashboard(),
          const SizedBox(height: 24),

          // 4. GESTIÓN OPERATIVA
          Text(
            'Gestión Operativa',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          _SectionCard(
            children: const [
               _SectionTile(
                icon: Icons.store_mall_directory_outlined,
                title: 'Mis Sucursales',
                subtitle: 'Gestiona direcciones y puntos de entrega',
              ),
              Divider(height: 1),
              _SectionTile(
                icon: Icons.people_outline,
                title: 'Equipo y Permisos',
                subtitle: 'Autoriza a tus jefes de cocina o compras',
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. FACTURACIÓN Y PAGOS
          Text(
            'Finanzas y Legal',
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          _SectionCard(
            children: const [
              _SectionTile(
                icon: Icons.receipt_long,
                title: 'Historial de Facturas',
                subtitle: 'Descarga XML/PDF de tus compras',
              ),
              Divider(height: 1),
              _SectionTile(
                icon: Icons.credit_card,
                title: 'Métodos de Pago',
                subtitle: 'Tarjetas corporativas y transferencias',
              ),
              Divider(height: 1),
               _SectionTile(
                icon: Icons.file_present_outlined,
                title: 'Certificados de Calidad',
                subtitle: 'Documentación para DIGESA/Municipalidad',
              ),
            ],
          ),
          const SizedBox(height: 24),

           // 6. CONFIGURACIÓN Y AYUDA
           _SectionCard(
            children: const [
               _SectionTile(
                icon: Icons.settings_outlined,
                title: 'Configuración',
                subtitle: 'Notificaciones y preferencias',
              ),
              Divider(height: 1),
              _SectionTile(
                icon: Icons.help_outline,
                title: 'Soporte Kuska',
                subtitle: 'Contacta a tu asesor comercial',
              ),
            ],
           ),

          const SizedBox(height: 32),
          // Cierre de sesión
          Center(
            child: TextButton.icon(
              onPressed: (){}, 
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text('Cerrar Sesión', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
          
          Center(
            child: Text(
              'Kuska B2B v1.0.0\nRUC 20600000001',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS DE ALTO VALOR ---

class _BusinessHeader extends StatelessWidget {
  const _BusinessHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
            image: const DecorationImage(
              image: AssetImage('assets/icons/logo_restaurante_mock.png'), // Mock o placeholder
              fit: BoxFit.cover
            ) 
          ),
           // Fallback
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Maido Cocina Nikkei',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 16, color: Color(0xFF00A67A))
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'RUC: 20513364221',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Cliente Kuska Pro',
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit_outlined, color: Colors.grey),
        )
      ],
    );
  }
}

class _CreditLineCard extends StatelessWidget {
  const _CreditLineCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002C28), Color(0xFF004D40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Color(0x40004D40), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Línea de Crédito Kuska',
                style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
              ),
              const Icon(Icons.trending_up, color: Colors.white, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'S/ 2,450.00',
            style: GoogleFonts.inter(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Disponible para compras inmediatas',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.3, // 30% usado
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A67A)),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usado: S/ 1,050', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
              Text('Total: S/ 3,500', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }
}

class _ImpactDashboard extends StatelessWidget {
  const _ImpactDashboard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu Impacto y Ahorro',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Row(
          children: const [
            Expanded(child: _ImpactMetric(label: 'Ahorro Total', value: 'S/ 850', icon: Icons.savings, color: Colors.orange)),
            SizedBox(width: 12),
            Expanded(child: _ImpactMetric(label: 'Mermas Evitadas', value: '45 kg', icon: Icons.eco, color: Colors.green)),
            SizedBox(width: 12),
            Expanded(child: _ImpactMetric(label: 'Score S³', value: '4.8', icon: Icons.star, color: Colors.purple)),
          ],
        ),
      ],
    );
  }
}

class _ImpactMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final MaterialColor color;

  const _ImpactMetric({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS GENÉRICOS DE UI ---
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 10, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: const Color(0xFF002C28), size: 20),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
      onTap: () {},
    );
  }
}