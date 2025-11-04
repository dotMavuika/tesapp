import 'package:flutter/material.dart';
import 'package:tesapp/controllers/finance_controller.dart';
import 'package:tesapp/model/finance_data.dart';

class FinanceView extends StatefulWidget {
  const FinanceView({super.key});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView> {
  final FinanceController _financeController = FinanceController();
  bool _isLoading = false; // Cambiado a false por defecto
  String? _errorMessage;
  FinanceData? _financeData;
  String _selectedFilter = 'todos';

  @override
  void initState() {
    super.initState();
    _initializeFinanceData();
  }

  // Método para inicializar los datos financieros
  void _initializeFinanceData() {
    // Primero intentar cargar datos desde GlobalVars
    final cachedData = _financeController.getFinanceData();

    if (cachedData != null) {
      // Si hay datos en caché, usarlos inmediatamente
      setState(() {
        _financeData = cachedData;
        _isLoading = false;
      });
      print('✅ Datos financieros cargados desde caché');
    } else {
      // Si no hay datos en caché, hacer la solicitud
      _loadFinanceData();
    }
  }

  Future<void> _loadFinanceData({bool forceRefresh = false}) async {
    // Si no es un refresh forzado y ya tenemos datos, no hacer nada
    if (!forceRefresh && _financeData != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _financeController.refreshFinanceData();

    if (result['success']) {
      setState(() {
        _financeData = _financeController.getFinanceData();
        _isLoading = false;
      });
      print('✅ Datos financieros actualizados desde API');
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
      print('❌ Error al cargar datos financieros: ${result['message']}');
    }
  }

  List<Rubro> _getFilteredRubros() {
    if (_financeData == null) return [];

    switch (_selectedFilter) {
      case 'pendientes':
        return _financeData!.rubrosPendientes;
      case 'pagados':
        return _financeData!.rubrosCancelados;
      default:
        return _financeData!.rubros;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
        backgroundColor: const Color(0xFFEEF1F8),
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
        actions: [
          // Botón de refresh - ahora fuerza la actualización
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.refresh),
                if (_isLoading)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _isLoading
                ? null
                : () => _loadFinanceData(forceRefresh: true),
          ),
        ],
      ),
      body: _isLoading && _financeData == null
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null && _financeData == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFinanceData(forceRefresh: true),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      )
          : _buildFinanceDataContent(),
    );
  }

  Widget _buildFinanceDataContent() {
    // Si no hay datos pero tampoco hay error (caso inicial)
    if (_financeData == null && _errorMessage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando datos financieros...'),
          ],
        ),
      );
    }

    // Si hay datos, mostrar el contenido normal
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
      ),
      child: RefreshIndicator(
        onRefresh: () => _loadFinanceData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Resumen financiero
              FinancialSummaryCard(financeData: _financeData!),

              const SizedBox(height: 16),

              // Progreso de pagos
              PaymentProgressCard(financeData: _financeData!),

              const SizedBox(height: 16),

              // Filtros
              FilterChips(
                selectedFilter: _selectedFilter,
                onFilterChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                totalCount: _financeData!.rubros.length,
                pendingCount: _financeData!.rubrosPendientes.length,
                paidCount: _financeData!.rubrosCancelados.length,
              ),

              const SizedBox(height: 16),

              // Lista de rubros agrupados
              RubrosGroupedList(rubros: _getFilteredRubros()),
            ],
          ),
        ),
      ),
    );
  }
}

// Card de resumen financiero
class FinancialSummaryCard extends StatelessWidget {
  final FinanceData financeData;

  const FinancialSummaryCard({super.key, required this.financeData});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF17203A), Color(0xFF7553F6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            'Balance Total',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${financeData.totalRubros.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.check_circle,
                label: 'Pagado',
                value: '\$${financeData.totalPagado.toStringAsFixed(2)}',
                color: Colors.green[300]!,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white30,
              ),
              _buildSummaryItem(
                icon: Icons.pending,
                label: 'Pendiente',
                value: '\$${financeData.totalAdeudado.toStringAsFixed(2)}',
                color: financeData.totalAdeudado > 0
                    ? Colors.orange[300]!
                    : Colors.green[300]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// Card de progreso de pagos
class PaymentProgressCard extends StatelessWidget {
  final FinanceData financeData;

  const PaymentProgressCard({super.key, required this.financeData});

  @override
  Widget build(BuildContext context) {
    final percentage = financeData.porcentajePagado;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Pagos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17203A),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7553F6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7553F6)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${financeData.rubrosCancelados.length} de ${financeData.rubros.length} rubros pagados',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Chips de filtro CORREGIDOS
class FilterChips extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final int totalCount;
  final int pendingCount;
  final int paidCount;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.totalCount,
    required this.pendingCount,
    required this.paidCount,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 4), // Pequeño margen inicial
          _buildFilterChip('Todos', 'todos', totalCount),
          const SizedBox(width: 8),
          _buildFilterChip('Pendientes', 'pendientes', pendingCount),
          const SizedBox(width: 8),
          _buildFilterChip('Pagados', 'pagados', paidCount),
          const SizedBox(width: 4), // Pequeño margen final
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = selectedFilter == value;

    return Container(
      constraints: const BoxConstraints(
        minWidth: 100, // Ancho mínimo para consistencia
      ),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13, // Texto ligeramente más pequeño
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11, // Texto más pequeño para el contador
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (selected) => onFilterChanged(value),
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF7553F6),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF7553F6) : Colors.grey[300]!,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// Lista agrupada de rubros CON BOTONES DESPLEGABLES
class RubrosGroupedList extends StatefulWidget {
  final List<Rubro> rubros;

  const RubrosGroupedList({super.key, required this.rubros});

  @override
  State<RubrosGroupedList> createState() => _RubrosGroupedListState();
}

class _RubrosGroupedListState extends State<RubrosGroupedList> {
  bool _showMatriculas = false;
  bool _showCuotas = false;

  @override
  Widget build(BuildContext context) {
    if (widget.rubros.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No hay rubros en esta categoría',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Agrupar por tipo
    final matriculas = widget.rubros.where((r) => r.tipo == 'MATRICULA').toList();
    final cuotas = widget.rubros.where((r) => r.tipo == 'CUOTA').toList();

    return Column(
      children: [
        if (matriculas.isNotEmpty)
          _buildExpandableGroupHeader(
            title: 'Matrículas',
            count: matriculas.length,
            isExpanded: _showMatriculas,
            onToggle: () {
              setState(() {
                _showMatriculas = !_showMatriculas;
              });
            },
            children: matriculas.map((rubro) => RubroCard(rubro: rubro)).toList(),
          ),

        if (cuotas.isNotEmpty)
          _buildExpandableGroupHeader(
            title: 'Cuotas',
            count: cuotas.length,
            isExpanded: _showCuotas,
            onToggle: () {
              setState(() {
                _showCuotas = !_showCuotas;
              });
            },
            children: cuotas.map((rubro) => RubroCard(rubro: rubro)).toList(),
          ),
      ],
    );
  }

  Widget _buildExpandableGroupHeader({
    required String title,
    required int count,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        // Encabezado con botón desplegable
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17203A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7553F6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7553F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: const Color(0xFF7553F6),
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),

        // Contenido desplegable
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// Card individual de rubro
class RubroCard extends StatelessWidget {
  final Rubro rubro;

  const RubroCard({super.key, required this.rubro});

  @override
  Widget build(BuildContext context) {
    final isPaid = rubro.cancelado;
    final isOverdue = rubro.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? Colors.green[200]!
              : isOverdue
              ? Colors.red[200]!
              : Colors.orange[200]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de estado
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isPaid
                  ? Colors.green[100]
                  : isOverdue
                  ? Colors.red[100]
                  : Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPaid
                  ? Icons.check_circle
                  : isOverdue
                  ? Icons.warning
                  : Icons.pending,
              color: isPaid
                  ? Colors.green[700]
                  : isOverdue
                  ? Colors.red[700]
                  : Colors.orange[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Información del rubro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rubro.nombre,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF17203A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      rubro.fechaVence,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Valor
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${rubro.valor.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17203A),
                ),
              ),
              if (!isPaid && rubro.valorPendiente > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Pendiente: \$${rubro.valorPendiente.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}