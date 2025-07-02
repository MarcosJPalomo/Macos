import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../providers/events_provider.dart';
import '../../utils/constants.dart';

class CreateEventScreen extends StatefulWidget {
  final EventModel? event; // Para editar evento existente

  const CreateEventScreen({Key? key, this.event}) : super(key: key);

  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _maxCapacityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 10, minute: 0);
  String _selectedCategory = EventCategory.fitness;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final event = widget.event!;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _instructorController.text = event.instructor;
    _maxCapacityController.text = event.maxCapacity.toString();
    _imageUrlController.text = event.imageUrl ?? '';
    _selectedDate = event.date;
    _selectedCategory = event.category;

    // Parse time strings
    final startParts = event.startTime.split(':');
    _startTime = TimeOfDay(
      hour: int.parse(startParts[0]),
      minute: int.parse(startParts[1]),
    );

    final endParts = event.endTime.split(':');
    _endTime = TimeOfDay(
      hour: int.parse(endParts[0]),
      minute: int.parse(endParts[1]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Crear Evento' : 'Editar Evento'),
        actions: [
          if (widget.event != null)
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(AppDimensions.paddingLarge),
          children: [
            _buildTextField(
              controller: _titleController,
              label: 'Título del evento',
              icon: Icons.title,
              validator: (value) => value?.isEmpty == true ? 'Título requerido' : null,
            ),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildTextField(
              controller: _descriptionController,
              label: 'Descripción',
              icon: Icons.description,
              maxLines: 3,
              validator: (value) => value?.isEmpty == true ? 'Descripción requerida' : null,
            ),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildTextField(
              controller: _instructorController,
              label: 'Instructor',
              icon: Icons.person,
              validator: (value) => value?.isEmpty == true ? 'Instructor requerido' : null,
            ),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildTextField(
              controller: _maxCapacityController,
              label: 'Capacidad máxima',
              icon: Icons.group,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isEmpty == true) return 'Capacidad requerida';
                final capacity = int.tryParse(value!);
                if (capacity == null || capacity <= 0) return 'Capacidad inválida';
                return null;
              },
            ),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildTextField(
              controller: _imageUrlController,
              label: 'URL de imagen (opcional)',
              icon: Icons.image,
            ),
            SizedBox(height: AppDimensions.paddingLarge),

            _buildDatePicker(),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildTimeSection(),
            SizedBox(height: AppDimensions.paddingMedium),

            _buildCategorySelector(),
            SizedBox(height: AppDimensions.paddingXLarge),

            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDatePicker() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mediumGray),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: ListTile(
        leading: Icon(Icons.calendar_today, color: AppColors.primary),
        title: Text('Fecha del evento'),
        subtitle: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: _selectDate,
      ),
    );
  }

  Widget _buildTimeSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.mediumGray),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: ListTile(
              leading: Icon(Icons.access_time, color: AppColors.primary),
              title: Text('Hora inicio'),
              subtitle: Text(_startTime.format(context)),
              onTap: () => _selectTime(true),
            ),
          ),
        ),
        SizedBox(width: AppDimensions.paddingMedium),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.mediumGray),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            ),
            child: ListTile(
              leading: Icon(Icons.access_time_filled, color: AppColors.primary),
              title: Text('Hora fin'),
              subtitle: Text(_endTime.format(context)),
              onTap: () => _selectTime(false),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: AppDimensions.fontLarge,
            fontWeight: FontWeight.w600,
            color: AppColors.dark,
          ),
        ),
        SizedBox(height: AppDimensions.paddingSmall),
        Wrap(
          spacing: AppDimensions.paddingSmall,
          runSpacing: AppDimensions.paddingSmall,
          children: EventCategory.categoryNames.entries.map((entry) {
            final isSelected = _selectedCategory == entry.key;
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    EventCategory.categoryIcons[entry.key],
                    size: 16,
                    color: isSelected ? AppColors.dark : AppColors.dark.withOpacity(0.7),
                  ),
                  SizedBox(width: 4),
                  Text(entry.value),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = entry.key);
                }
              },
              backgroundColor: AppColors.lightGray,
              selectedColor: AppColors.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _saveEvent,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.dark,
        padding: EdgeInsets.symmetric(vertical: AppDimensions.paddingLarge),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: _isLoading
          ? CircularProgressIndicator(color: AppColors.dark)
          : Text(
        widget.event == null ? 'Crear Evento' : 'Actualizar Evento',
        style: TextStyle(
          fontSize: AppDimensions.fontLarge,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime(bool isStartTime) async {
    final time = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (time != null) {
      setState(() {
        if (isStartTime) {
          _startTime = time;
        } else {
          _endTime = time;
        }
      });
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar horarios
    final startMinutes = _startTime.hour * 60 + _startTime.minute;
    final endMinutes = _endTime.hour * 60 + _endTime.minute;

    if (endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La hora de fin debe ser posterior a la hora de inicio'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final event = EventModel(
        id: widget.event?.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate,
        startTime: '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        endTime: '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        maxCapacity: int.parse(_maxCapacityController.text),
        currentBookings: widget.event?.currentBookings ?? 0,
        instructor: _instructorController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        category: _selectedCategory,
        createdAt: widget.event?.createdAt ?? DateTime.now(),
      );

      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      bool success;

      if (widget.event == null) {
        success = await eventsProvider.createEvent(event);
      } else {
        success = await eventsProvider.updateEvent(event);
      }

      if (success) {
        eventsProvider.loadEvents();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.event == null ? 'Evento creado exitosamente' : 'Evento actualizado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventsProvider.error ?? 'Error al guardar evento'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar evento'),
        content: Text('¿Estás seguro de que quieres eliminar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent();
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent() async {
    if (widget.event == null) return;

    setState(() => _isLoading = true);

    try {
      final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
      final success = await eventsProvider.deleteEvent(widget.event!.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Evento eliminado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(eventsProvider.error ?? 'Error al eliminar evento'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _maxCapacityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}