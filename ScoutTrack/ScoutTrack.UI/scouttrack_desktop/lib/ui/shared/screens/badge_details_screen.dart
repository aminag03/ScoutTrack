import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/models/badge.dart';
import 'package:scouttrack_desktop/models/badge_requirement.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/badge_requirement_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';

import 'dart:convert';
import 'package:scouttrack_desktop/utils/error_utils.dart';

class BadgeDetailsScreen extends StatefulWidget {
  final Badge badge;
  final String role;
  final int loggedInUserId;

  const BadgeDetailsScreen({
    super.key,
    required this.badge,
    required this.role,
    required this.loggedInUserId,
  });

  @override
  State<BadgeDetailsScreen> createState() => _BadgeDetailsScreenState();
}

class _BadgeDetailsScreenState extends State<BadgeDetailsScreen> {
  List<BadgeRequirement> _requirements = [];
  bool _loadingRequirements = false;
  final ScrollController _scrollController = ScrollController();

  late BadgeRequirementProvider _badgeRequirementProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _badgeRequirementProvider = BadgeRequirementProvider(authProvider);
    _loadRequirements();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRequirements() async {
    setState(() {
      _loadingRequirements = true;
    });

    try {
      final filter = {
        'BadgeId': widget.badge.id,
        'Page': 0,
        'PageSize': 100, // Load more requirements at once
        'IncludeTotalCount': false,
      };

      final result = await _badgeRequirementProvider.get(filter: filter);
      setState(() {
        _requirements = result.items?.cast<BadgeRequirement>() ?? [];
        _loadingRequirements = false;
      });
    } catch (e) {
      showErrorSnackbar(context, e);
    }
  }

  void _showAddRequirementDialog() {
    if (_requirements.length >= 20) {
      showErrorSnackbar(
        context,
        'Dostignut je maksimalan broj zahtjeva (20). Nije moguće dodati nove zahtjeve.',
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => BadgeRequirementFormDialog(
        badgeId: widget.badge.id,
        onRequirementAdded: _loadRequirements,
      ),
    );
  }

  void _showEditRequirementDialog(BadgeRequirement requirement) {
    showDialog(
      context: context,
      builder: (context) => BadgeRequirementFormDialog(
        badgeId: widget.badge.id,
        requirement: requirement,
        onRequirementAdded: _loadRequirements,
      ),
    );
  }

  Future<void> _deleteRequirement(BadgeRequirement requirement) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Potvrda brisanja'),
        content: Text(
          'Jeste li sigurni da želite obrisati zahtjev "${requirement.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Obriši'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _badgeRequirementProvider.delete(requirement.id);
        _loadRequirements();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zahtjev je uspješno obrisan')),
          );
        }
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: widget.role,
      selectedMenu: 'Vještarstva',
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8E1),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(Icons.arrow_back),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  widget.badge.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFF),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.green,
                                  width: 4,
                                ),
                              ),
                              child: widget.badge.imageUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        widget.badge.imageUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.emoji_events,
                                                color: Colors.amber,
                                                size: 60,
                                              );
                                            },
                                      ),
                                    )
                                  : const Icon(
                                      Icons.emoji_events,
                                      color: Colors.amber,
                                      size: 60,
                                    ),
                            ),

                            const SizedBox(width: 24),

                            // Badge details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.badge.description.isNotEmpty) ...[
                                    Text(
                                      'Opis:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.badge.description,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                  ],

                                  Text(
                                    'Kreirano: ${formatDateTime(widget.badge.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),

                                  if (widget.badge.updatedAt != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ažurirano: ${formatDateTime(widget.badge.updatedAt!)}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Requirements section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Zahtjevi za vještarstvo:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  '${_requirements.length}/20',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _requirements.length >= 18
                                        ? Colors.orange
                                        : _requirements.length >= 15
                                        ? Colors.blue
                                        : Colors.grey.shade600,
                                    fontWeight: _requirements.length >= 18
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.role == 'Admin')
                              ElevatedButton.icon(
                                onPressed: _requirements.length >= 20
                                    ? null
                                    : _showAddRequirementDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Dodaj zahtjev'),
                              ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Warning when limit reached
                        if (_requirements.length >= 20)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              border: Border.all(color: Colors.orange.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Dostignut je maksimalan broj zahtjeva (20). Nije moguće dodati nove zahtjeve.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_requirements.length >= 20)
                          const SizedBox(height: 8),

                        if (_requirements.length >= 15 &&
                            _requirements.length < 20)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              border: Border.all(color: Colors.blue.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Približavate se maksimalnom broju zahtjeva. Preostalo: ${20 - _requirements.length} zahtjeva.',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (_requirements.length >= 15 &&
                            _requirements.length < 20)
                          const SizedBox(height: 8),

                        // Requirements list
                        if (_loadingRequirements)
                          const Center(child: CircularProgressIndicator())
                        else if (_requirements.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Nema definiranih zahtjeva za ovo vještarstvo.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Scrollbar(
                                      controller: _scrollController,
                                      thumbVisibility:
                                          true,
                                      thickness:
                                          6,
                                      radius: const Radius.circular(3),
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        padding: const EdgeInsets.all(8),
                                        itemCount: _requirements.length,
                                        itemBuilder: (context, index) {
                                          final requirement =
                                              _requirements[index];
                                          return Card(
                                            margin: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: ListTile(
                                              title: Text(
                                                requirement.description,
                                              ),
                                              subtitle: Text(
                                                'Kreirano: ${formatDateTime(requirement.createdAt)}',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              trailing: widget.role == 'Admin'
                                                  ? Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        IconButton(
                                                          onPressed: () =>
                                                              _showEditRequirementDialog(
                                                                requirement,
                                                              ),
                                                          icon: const Icon(
                                                            Icons.edit,
                                                            size: 20,
                                                          ),
                                                          tooltip: 'Uredi',
                                                        ),
                                                        IconButton(
                                                          onPressed: () =>
                                                              _deleteRequirement(
                                                                requirement,
                                                              ),
                                                          icon: const Icon(
                                                            Icons.delete,
                                                            size: 20,
                                                          ),
                                                          tooltip: 'Obriši',
                                                          color: Colors.red,
                                                        ),
                                                      ],
                                                    )
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 24),

              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Završili',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prikaži sve',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade400,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amina Gutošić',
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'U toku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Prikaži sve',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Expanded(
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                            itemCount: 8,
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey.shade400,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Amina Gutošić',
                                      style: const TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BadgeRequirementFormDialog extends StatefulWidget {
  final int badgeId;
  final BadgeRequirement? requirement;
  final VoidCallback onRequirementAdded;

  const BadgeRequirementFormDialog({
    super.key,
    required this.badgeId,
    this.requirement,
    required this.onRequirementAdded,
  });

  @override
  State<BadgeRequirementFormDialog> createState() =>
      _BadgeRequirementFormDialogState();
}

class _BadgeRequirementFormDialogState
    extends State<BadgeRequirementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.requirement != null) {
      _descriptionController.text = widget.requirement!.description;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRequirement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requirementProvider = BadgeRequirementProvider(authProvider);

      if (widget.requirement == null) {
        await requirementProvider.create(
          badgeId: widget.badgeId,
          description: _descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zahtjev je uspješno kreiran')),
          );
        }
      } else {
        await requirementProvider.updateBadgeRequirement(
          id: widget.requirement!.id,
          badgeId: widget.badgeId,
          description: _descriptionController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zahtjev je uspješno ažuriran')),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onRequirementAdded();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showErrorSnackbar(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.requirement != null;

    return AlertDialog(
      title: Text(isEditing ? 'Uredi zahtjev' : 'Dodaj novi zahtjev'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Opis zahtjeva *',
                  border: OutlineInputBorder(),
                  helperText: 'Maksimalno 500 znakova',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Opis je obavezan';
                  }
                  if (value.trim().length > 500) {
                    return 'Opis ne smije biti duži od 500 znakova';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() {});
                  }
                },
              ),

              // Character counter
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${_descriptionController.text.length}/500',
                    style: TextStyle(
                      fontSize: 12,
                      color: _descriptionController.text.length > 450
                          ? Colors.orange
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),

              if (!isEditing) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Maksimalan broj zahtjeva po vještarstvu je 20.',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Odustani'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveRequirement,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Ažuriraj' : 'Kreiraj'),
        ),
      ],
    );
  }
}
