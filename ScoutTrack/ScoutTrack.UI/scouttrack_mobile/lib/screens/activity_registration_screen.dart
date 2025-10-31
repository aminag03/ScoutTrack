import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/activity_registration_provider.dart';
import '../providers/member_provider.dart';
import '../models/activity.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';

class ActivityRegistrationScreen extends StatefulWidget {
  final Activity activity;

  const ActivityRegistrationScreen({super.key, required this.activity});

  @override
  State<ActivityRegistrationScreen> createState() =>
      _ActivityRegistrationScreenState();
}

class _ActivityRegistrationScreenState
    extends State<ActivityRegistrationScreen> {
  bool _isConfirmed = false;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  int? _currentUserTroopId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserTroop();
  }

  Future<void> _loadCurrentUserTroop() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = MemberProvider(authProvider);
      final userId = await authProvider.getUserIdFromToken();
      if (userId != null) {
        final member = await memberProvider.getById(userId);
        if (mounted) {
          setState(() {
            _currentUserTroopId = member.troopId;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRegistration() async {
    if (!_isConfirmed) return;
    if (!_isRegistrationAllowed()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final registrationProvider = ActivityRegistrationProvider(authProvider);

      await registrationProvider.createRegistration(
        activityId: widget.activity.id,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        SnackBarUtils.showSuccessSnackBar(
          'Prijava je uspješno poslana',
          context: context,
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Prijava na aktivnost',
      selectedIndex: -1,
      body: Container(
        color: const Color(0xFFF5F5DC),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivityInfoCard(),

              if (_isRegistrationAllowed()) ...[
                const SizedBox(height: 24),
                _buildRegistrationFormCard(),
              ] else ...[
                const SizedBox(height: 24),
                _buildUnavailableRegistrationCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isRegistrationAllowed() {
    if (widget.activity.isPrivate &&
        _currentUserTroopId != null &&
        widget.activity.troopId != _currentUserTroopId) {
      return false;
    }
    if (widget.activity.activityState == 'DraftActivityState' ||
        widget.activity.activityState == 'CancelledActivityState') {
      return false;
    }
    return true;
  }

  Widget _buildActivityInfoCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.activity.imagePath.isNotEmpty) ...[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                UrlUtils.buildImageUrl(widget.activity.imagePath),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.activity.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),

                if (widget.activity.activityTypeName.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      widget.activity.activityTypeName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (widget.activity.startTime != null) ...[
                  _buildInfoRow(
                    Icons.play_arrow,
                    'Početak',
                    DateFormat(
                      'dd.MM.yyyy HH:mm',
                    ).format(widget.activity.startTime!),
                  ),
                ],

                if (widget.activity.endTime != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.stop,
                    'Kraj',
                    DateFormat(
                      'dd.MM.yyyy HH:mm',
                    ).format(widget.activity.endTime!),
                  ),
                ],

                if (widget.activity.locationName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    'Lokacija',
                    widget.activity.locationName,
                  ),
                ],

                if (widget.activity.troopName.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.group,
                    'Odred',
                    widget.activity.troopName,
                  ),
                ],

                if (widget.activity.fee > 0) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.payments,
                    'Cijena',
                    '${widget.activity.fee.toStringAsFixed(0)} KM',
                  ),
                ],

                if (widget.activity.description.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Opis aktivnosti',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationFormCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prijava na aktivnost',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isConfirmed
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isConfirmed
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isConfirmed,
                    onChanged: (value) {
                      setState(() {
                        _isConfirmed = value ?? false;
                      });
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isConfirmed = !_isConfirmed;
                        });
                      },
                      child: Text(
                        'Potvrđujem svoje učešće na ovoj aktivnosti',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isConfirmed
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Bilješka (opcionalno)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Unesite bilješku ili dodatne informacije...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(fontSize: 14),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConfirmed && !_isLoading
                    ? _submitRegistration
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfirmed && !_isLoading
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: _isConfirmed && !_isLoading ? 4 : 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Pošalji prijavu',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnavailableRegistrationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Prijava na aktivnost',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange[700],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.activity.activityState == 'DraftActivityState'
                        ? 'Aktivnost je u nacrtu'
                        : 'Aktivnost je otkazana',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.activity.activityState == 'DraftActivityState'
                        ? 'Ova aktivnost je trenutno u nacrtu i nije dostupna za prijave. Molimo pričekajte dok organizator ne aktivira aktivnost.'
                        : 'Ova aktivnost je otkazana i nije moguće se prijaviti na nju.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.orange[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
