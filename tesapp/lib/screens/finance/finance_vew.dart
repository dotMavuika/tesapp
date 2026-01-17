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
  bool _isLoading = false;
  String? _errorMessage;
  FinanceData? _financeData;
  String _selectedFilter = 'todos';

  // Paleta consistente con GradesScreen
  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);
  static const Color _background = Colors.white;

  @override
  void initState() {
    super.initState();
    _initializeFinanceData();
  }

  void _initializeFinanceData() {
    final cachedData = _financeController.getFinanceData();

    if (cachedData != null) {
      setState(() {
        _financeData = cachedData;
        _isLoading = false;
      });
    } else {
      _loadFinanceData();
    }
  }

  Future<void> _loadFinanceData({bool forceRefresh = false}) async {
    if (!forceRefresh && _financeData != null) return;

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
    } else {
      setState(() {
        _errorMessage = result['message'];
        _isLoading = false;
      });
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
      backgroundColor: _background,
      appBar: AppBar(
        title: const Text('Finanzas'),
        centerTitle: true,
        toolbarHeight: 64,
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(
          color: _primaryPurple,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        foregroundColor: _primaryPurple,
        actions: [
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
                        color: _primaryYellow,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed:
            _isLoading ? null : () => _loadFinanceData(forceRefresh: true),
          ),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _financeData == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: _primaryPurple,
        ),
      );
    }

    if (_errorMessage != null && _financeData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 60, color: _primaryPurple),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  fontSize: 16,
                  color: _primaryPurple,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadFinanceData(forceRefresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryYellow,
                foregroundColor: _primaryPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return _buildFinanceDataContent();
  }

  Widget _buildFinanceDataContent() {
    if (_financeData == null && _errorMessage == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: _primaryPurple),
            SizedBox(height: 16),
            Text(
              'Cargando datos financieros...',
              style: TextStyle(color: _primaryPurple),
            ),
          ],
        ),
      );
    }

    return Container(
      color: _background,
      child: RefreshIndicator(
        color: _primaryPurple,
        onRefresh: () => _loadFinanceData(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FinancialSummaryCard(financeData: _financeData!),
              const SizedBox(height: 16),
              PaymentProgressCard(financeData: _financeData!),
              const SizedBox(height: 16),
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
              RubrosGroupedList(rubros: _getFilteredRubros()),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de resumen financiero (degradado morado, texto blanco, íconos amarillos)
// ─────────────────────────────────────────────────────────────────────────────

class FinancialSummaryCard extends StatelessWidget {
  final FinanceData financeData;

  const FinancialSummaryCard({super.key, required this.financeData});

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primaryPurple, _secondaryPurple],
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
  }) {
    return Column(
      children: [
        Icon(icon, color: _primaryYellow, size: 28), // ÍCONO AMARILLO
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
          style: const TextStyle(
            color: Colors.white, // TEXTO BLANCO
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de progreso de pagos (mismo estilo de tarjeta, pero más light)
// ─────────────────────────────────────────────────────────────────────────────

class PaymentProgressCard extends StatelessWidget {
  final FinanceData financeData;

  const PaymentProgressCard({super.key, required this.financeData});

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  Widget build(BuildContext context) {
    final int totalRubros = financeData.rubros.length;
    final int paidRubros = financeData.rubrosCancelados.length;
    final double percentageByCount =
    totalRubros == 0 ? 0.0 : (paidRubros / totalRubros) * 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _primaryPurple.withOpacity(0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + porcentaje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Pagos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryPurple,
                ),
              ),
              Text(
                '${percentageByCount.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _primaryYellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barra de progreso
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentageByCount / 100,
              minHeight: 12,
              backgroundColor: _primaryPurple.withOpacity(0.15),
              valueColor:
              const AlwaysStoppedAnimation<Color>(_primaryYellow),
            ),
          ),
          const SizedBox(height: 12),
          // Conteo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$paidRubros de $totalRubros rubros pagados',
                style: TextStyle(
                  fontSize: 14,
                  color: _primaryPurple.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chips de filtro con paleta morado/amarillo
// ─────────────────────────────────────────────────────────────────────────────

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

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          const SizedBox(width: 4),
          _buildFilterChip('Todos', 'todos', totalCount),
          const SizedBox(width: 8),
          _buildFilterChip('Pendientes', 'pendientes', pendingCount),
          const SizedBox(width: 8),
          _buildFilterChip('Pagados', 'pagados', paidCount),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = selectedFilter == value;

    return Container(
      constraints: const BoxConstraints(minWidth: 100),
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
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? _primaryYellow.withOpacity(0.2)
                    : _primaryPurple.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? _primaryPurple : _primaryPurple,
                ),
              ),
            ),
          ],
        ),
        selected: isSelected,
        onSelected: (_) => onFilterChanged(value),
        backgroundColor: Colors.white,
        selectedColor: _primaryPurple,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : _primaryPurple,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? _primaryPurple
                : _primaryPurple.withOpacity(0.2),
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lista agrupada de rubros (headers blancos, cards moradas)
// ─────────────────────────────────────────────────────────────────────────────

class RubrosGroupedList extends StatefulWidget {
  final List<Rubro> rubros;

  const RubrosGroupedList({super.key, required this.rubros});

  @override
  State<RubrosGroupedList> createState() => _RubrosGroupedListState();
}

class _RubrosGroupedListState extends State<RubrosGroupedList> {
  bool _showMatriculas = false;
  bool _showCuotas = false;

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  Widget build(BuildContext context) {
    if (widget.rubros.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined,
                size: 60, color: _primaryPurple.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'No hay rubros en esta categoría',
              style: TextStyle(
                fontSize: 16,
                color: _primaryPurple.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    final matriculas =
    widget.rubros.where((r) => r.tipo == 'MATRICULA').toList();
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
            children:
            matriculas.map((rubro) => RubroCard(rubro: rubro)).toList(),
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
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _primaryPurple.withOpacity(0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryPurple.withOpacity(0.04),
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
                        color: _primaryPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _primaryPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: _primaryPurple,
                ),
                onPressed: onToggle,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 8),
          ...children,
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card individual de rubro (degradado morado, texto blanco, íconos amarillos)
// ─────────────────────────────────────────────────────────────────────────────

class RubroCard extends StatelessWidget {
  final Rubro rubro;

  const RubroCard({super.key, required this.rubro});

  static const Color _primaryPurple = Color(0xFF7C3E8E);
  static const Color _secondaryPurple = Color(0xFF9A56A8);
  static const Color _primaryYellow = Color(0xFFE6B420);

  @override
  Widget build(BuildContext context) {
    final bool isPaid = rubro.cancelado;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryPurple, _secondaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _primaryYellow,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryPurple.withOpacity(0.08),
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
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPaid ? Icons.check_circle : Icons.pending,
              color: _primaryYellow,
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
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 14, color: _primaryYellow),
                    const SizedBox(width: 4),
                    Text(
                      rubro.fechaVence,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
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
                  color: _primaryYellow,
                ),
              ),
              if (!isPaid && rubro.valorPendiente > 0) ...[
                const SizedBox(height: 2),
                Text(
                  'Pendiente: \$${rubro.valorPendiente.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
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
