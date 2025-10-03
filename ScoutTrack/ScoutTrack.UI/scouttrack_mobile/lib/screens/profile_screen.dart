import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../layouts/master_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/member_provider.dart';
import '../providers/city_provider.dart';
import '../providers/troop_provider.dart';
import '../models/member.dart';
import '../models/city.dart';
import '../screens/troop_details_screen.dart';
import '../screens/activity_list_screen.dart';
import '../utils/url_utils.dart';
import '../utils/snackbar_utils.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Member? _currentMember;
  bool _isLoading = true;
  String? _error;
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  List<City> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadMemberData();
  }

  Future<void> _loadMemberData() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );
      final cityProvider = CityProvider(authProvider);

      final userInfo = await authProvider.getCurrentUserInfo();
      if (userInfo != null && userInfo['id'] != null) {
        final memberId = userInfo['id'] as int;

        final futures = await Future.wait([
          memberProvider.getById(memberId),
          cityProvider.get(filter: {"RetrieveAll": true}),
        ]);

        final member = futures[0] as Member;
        final cityResult = futures[1] as dynamic;

        if (mounted) {
          setState(() {
            _currentMember = member;
            _cities = cityResult.items ?? [];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Nije moguće dohvatiti podatke o članu';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Greška pri učitavanju podataka: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToTroop() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani.',
        context: context,
      );
      return;
    }

    if (_currentMember!.troopId == 0) {
      SnackBarUtils.showWarningSnackBar(
        'Niste povezani sa odredom.',
        context: context,
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final troopProvider = TroopProvider(authProvider);

      final troop = await troopProvider.getById(_currentMember!.troopId);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TroopDetailsScreen(troop: troop),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _navigateToMyActivities() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani.',
        context: context,
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ActivityListScreen(
          memberId: _currentMember!.id,
          title: 'Moje aktivnosti',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      headerTitle: 'Moj profil',
      selectedIndex: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white, size: 24),
          onPressed: _showEditProfileDialog,
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          onPressed: _showChangePasswordDialog,
        ),
      ],
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(fontSize: 16, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMemberData,
              child: const Text('Pokušaj ponovo'),
            ),
          ],
        ),
      );
    }

    if (_currentMember == null) {
      return const Center(child: Text('Nema podataka o članu'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileOptions(),
          const SizedBox(height: 32),
          _buildDeleteProfileButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                backgroundImage: _currentMember!.profilePictureUrl.isNotEmpty
                    ? NetworkImage(
                        UrlUtils.buildImageUrl(
                          _currentMember!.profilePictureUrl,
                        ),
                      )
                    : null,
                child: _currentMember!.profilePictureUrl.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _showImagePickerDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
              if (_currentMember!.profilePictureUrl.isNotEmpty)
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: GestureDetector(
                    onTap: _showDeleteImageDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${_currentMember!.firstName} ${_currentMember!.lastName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '@${_currentMember!.username}',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _navigateToTroop,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Odred izviđača "${_currentMember!.troopName}"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email, 'Email', _currentMember!.email),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone, 'Telefon', _currentMember!.contactPhone),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_city, 'Grad', _currentMember!.cityName),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.cake,
            'Datum rođenja',
            '${_currentMember!.birthDate.day}.${_currentMember!.birthDate.month}.${_currentMember!.birthDate.year}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            _currentMember!.gender == 0 ? Icons.male : Icons.female,
            'Spol',
            _currentMember!.gender == 0 ? 'Muški' : 'Ženski',
          ),
          if (_currentMember!.categoryName.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.category,
              'Kategorija',
              _currentMember!.categoryName,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'Nije uneseno',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions() {
    return Column(
      children: [
        _buildOptionCard(
          icon: Icons.list_alt,
          title: 'Moje prijave',
          subtitle: 'Pregledajte svoje prijave za aktivnosti',
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ActivityListScreen(
                  title: 'Moje prijave',
                  showMyRegistrations: true,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.event,
          title: 'Moje aktivnosti',
          subtitle: 'Aktivnosti u kojima ste sudjelovali',
          onTap: _navigateToMyActivities,
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          icon: Icons.star,
          title: 'Moja vještarstva',
          subtitle: 'Vaš napredak u vještarstvima',
          onTap: () {
            // TODO: Navigate to skills/badges
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDeleteProfileButton() {
    return Center(
      child: GestureDetector(
        onTap: _showDeleteProfileDialog,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.delete_forever, color: Colors.red, size: 32),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 4,
          width: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    final resized = img.copyResize(image, width: 400, height: 400);
    final compressed = img.encodeJpg(resized, quality: 85);
    return Uint8List.fromList(compressed);
  }

  Future<void> _showImagePickerDialog() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani. Molimo pokušajte ponovo.',
        context: context,
      );
      return;
    }

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Promijeni profilnu fotografiju'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedImageBytes != null ||
                      _currentMember!.profilePictureUrl.isNotEmpty)
                    Stack(
                      children: [
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : (_currentMember!.profilePictureUrl.isNotEmpty
                                      ? Image.network(
                                          UrlUtils.buildImageUrl(
                                            _currentMember!.profilePictureUrl,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 50,
                                                  ),
                                                );
                                              },
                                        )
                                      : const Center(
                                          child: Icon(Icons.person, size: 50),
                                        )),
                          ),
                        ),
                      ],
                    )
                  else
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          maxWidth: 400,
                          maxHeight: 400,
                          imageQuality: 85,
                        );
                        if (pickedFile != null) {
                          final bytes = await pickedFile.readAsBytes();
                          final compressedBytes = await _compressImage(bytes);
                          setState(() {
                            _selectedImageBytes = compressedBytes;
                            _selectedImageFile = File(pickedFile.path);
                          });
                        }
                      } catch (e) {
                        if (context.mounted) {
                          SnackBarUtils.showErrorSnackBar(e, context: context);
                        }
                      }
                    },
                    child: const Text('Odaberi fotografiju'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _selectedImageBytes = null;
                  _selectedImageFile = null;
                  Navigator.of(context).pop(false);
                },
                child: const Text('Otkaži'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: _selectedImageBytes != null
                    ? () => Navigator.of(context).pop(true)
                    : null,
                child: const Text('Sačuvaj'),
              ),
            ],
          );
        },
      ),
    );

    if (shouldSave == true && _selectedImageFile != null) {
      await _uploadImage(_selectedImageFile!);
    }

    setState(() {
      _selectedImageBytes = null;
      _selectedImageFile = null;
    });
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );

      await memberProvider.updateProfilePicture(_currentMember!.id, imageFile);

      final refreshedMember = await memberProvider.getById(_currentMember!.id);

      if (mounted) {
        setState(() {
          _currentMember = refreshedMember;
        });
      }

      if (context.mounted) {
        SnackBarUtils.showSuccessSnackBar(
          'Profilna fotografija je uspješno promijenjena.',
          context: context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _showDeleteImageDialog() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani. Molimo pokušajte ponovo.',
        context: context,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Obriši profilnu fotografiju'),
        content: const Text(
          'Jeste li sigurni da želite obrisati profilnu fotografiju?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Odustani'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Obriši', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteImage();
    }
  }

  Future<void> _deleteImage() async {
    try {
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );

      await memberProvider.updateProfilePicture(_currentMember!.id, null);

      final refreshedMember = await memberProvider.getById(_currentMember!.id);

      if (mounted) {
        setState(() {
          _currentMember = refreshedMember;
        });
      }

      if (context.mounted) {
        SnackBarUtils.showSuccessSnackBar(
          'Profilna fotografija je uspješno obrisana.',
          context: context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani. Molimo pokušajte ponovo.',
        context: context,
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final firstNameController = TextEditingController(
      text: _currentMember!.firstName,
    );
    final lastNameController = TextEditingController(
      text: _currentMember!.lastName,
    );
    final usernameController = TextEditingController(
      text: _currentMember!.username,
    );
    final emailController = TextEditingController(text: _currentMember!.email);
    final contactPhoneController = TextEditingController(
      text: _currentMember!.contactPhone,
    );
    final birthDateController = TextEditingController(
      text:
          '${_currentMember!.birthDate.day}.${_currentMember!.birthDate.month}.${_currentMember!.birthDate.year}',
    );

    int? selectedGender = _currentMember!.gender;
    int? selectedCityId = _currentMember!.cityId;

    final originalContext = context;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
                maxWidth: MediaQuery.of(context).size.width * 0.95,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Uredi profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(Icons.close, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Lični podaci'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: firstNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Ime *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      errorMaxLines: 3,
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Ime je obavezno.';
                                      }
                                      if (value.length > 50) {
                                        return 'Ime ne smije imati više od 50 znakova.';
                                      }
                                      final regex = RegExp(
                                        r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$",
                                      );
                                      if (!regex.hasMatch(value.trim())) {
                                        return 'Ime može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: lastNameController,
                                    decoration: InputDecoration(
                                      labelText: 'Prezime *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      errorMaxLines: 3,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Prezime je obavezno.';
                                      }
                                      if (value.length > 50) {
                                        return 'Prezime ne smije imati više od 50 znakova.';
                                      }
                                      final regex = RegExp(
                                        r"^[A-Za-zČčĆćŽžĐđŠš\s\-]+$",
                                      );
                                      if (!regex.hasMatch(value.trim())) {
                                        return 'Prezime može sadržavati samo slova (A-Ž, a-ž), razmake i crtice (-).';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: 'Korisničko ime *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                errorMaxLines: 3,
                                prefixIcon: const Icon(Icons.alternate_email),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Korisničko ime je obavezno.';
                                }
                                if (value.length > 50) {
                                  return 'Korisničko ime ne smije imati više od 50 znakova.';
                                }
                                if (!RegExp(
                                  r"^[A-Za-z0-9_.]+$",
                                ).hasMatch(value.trim())) {
                                  return 'Korisničko ime može sadržavati samo slova, brojeve, tačke ili donje crte.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionHeader('Kontakt podaci'),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'E-mail *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                errorMaxLines: 3,
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'E-mail je obavezan.';
                                }
                                if (value.length > 100) {
                                  return 'E-mail ne smije imati više od 100 znakova.';
                                }
                                if (!RegExp(
                                  r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$",
                                ).hasMatch(value.trim())) {
                                  return 'Unesite ispravan e-mail.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: contactPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Telefon *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                errorMaxLines: 3,
                                prefixIcon: const Icon(Icons.phone_outlined),
                                hintText: '+387 6X XXX XXX',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Telefon je obavezan.';
                                }
                                if (value.length > 20) {
                                  return 'Telefon ne smije imati više od 20 znakova.';
                                }
                                if (!RegExp(
                                  r'^(\+387|0)[6][0-7][0-9][0-9][0-9][0-9][0-9][0-9]$',
                                ).hasMatch(value)) {
                                  return 'Broj telefona mora biti validan za Bosnu i Hercegovinu.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 24),

                            _buildSectionHeader('Dodatni podaci'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: selectedGender,
                                    decoration: InputDecoration(
                                      labelText: 'Spol *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      errorMaxLines: 3,
                                      prefixIcon: const Icon(Icons.wc),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 0,
                                        child: Text(
                                          'Muški',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 1,
                                        child: Text(
                                          'Ženski',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Spol je obavezan.';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedGender = val;
                                      });
                                    },
                                    isExpanded: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: selectedCityId,
                                    decoration: InputDecoration(
                                      labelText: 'Grad *',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      errorMaxLines: 3,
                                      prefixIcon: const Icon(
                                        Icons.location_city,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 16,
                                          ),
                                    ),
                                    items: _cities
                                        .map(
                                          (c) => DropdownMenuItem<int>(
                                            value: c.id,
                                            child: Text(
                                              c.name,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Grad je obavezan.';
                                      }
                                      return null;
                                    },
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (val) {
                                      setState(() {
                                        selectedCityId = val;
                                      });
                                    },
                                    isExpanded: true,
                                    menuMaxHeight:
                                        MediaQuery.of(context).size.height *
                                        0.4,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: birthDateController,
                              decoration: InputDecoration(
                                labelText: 'Datum rođenja *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: 'Odaberite datum',
                                errorMaxLines: 3,
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: const Icon(Icons.arrow_drop_down),
                              ),
                              readOnly: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Datum rođenja je obavezan.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              onTap: () async {
                                DateTime initialDate =
                                    _currentMember!.birthDate;
                                if (birthDateController.text.isNotEmpty) {
                                  try {
                                    final parts = birthDateController.text
                                        .split('.');
                                    if (parts.length == 3) {
                                      initialDate = DateTime(
                                        int.parse(parts[2]),
                                        int.parse(parts[1]),
                                        int.parse(parts[0]),
                                      );
                                    }
                                  } catch (e) {
                                    initialDate = _currentMember!.birthDate;
                                  }
                                }

                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                  helpText: 'Odaberite datum rođenja',
                                  cancelText: 'Otkaži',
                                  confirmText: 'Potvrdi',
                                  fieldHintText: 'DD/MM/YYYY',
                                  fieldLabelText: 'Datum rođenja',
                                );
                                if (picked != null) {
                                  setState(() {
                                    birthDateController.text =
                                        '${picked.day}.${picked.month}.${picked.year}';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Text(
                              'Otkaži',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  DateTime birthDate =
                                      _currentMember!.birthDate;
                                  if (birthDateController.text.isNotEmpty) {
                                    final parts = birthDateController.text
                                        .split('.');
                                    if (parts.length == 3) {
                                      birthDate = DateTime(
                                        int.parse(parts[2]),
                                        int.parse(parts[1]),
                                        int.parse(parts[0]),
                                      );
                                    }
                                  }

                                  final requestBody = {
                                    "FirstName": firstNameController.text
                                        .trim(),
                                    "LastName": lastNameController.text.trim(),
                                    "Username": usernameController.text.trim(),
                                    "Email": emailController.text.trim(),
                                    "ContactPhone": contactPhoneController.text
                                        .trim(),
                                    "BirthDate": birthDate.toIso8601String(),
                                    "Gender": selectedGender,
                                    "CityId": selectedCityId,
                                    "TroopId": _currentMember!.troopId,
                                  };

                                  final memberProvider =
                                      Provider.of<MemberProvider>(
                                        context,
                                        listen: false,
                                      );
                                  await memberProvider.update(
                                    _currentMember!.id,
                                    requestBody,
                                  );

                                  if (context.mounted) {
                                    SnackBarUtils.showSuccessSnackBar(
                                      'Profil je uspješno ažuriran.',
                                      context: context,
                                    );
                                  }

                                  Navigator.of(context).pop(true);
                                } catch (e) {
                                  if (context.mounted) {
                                    SnackBarUtils.showErrorSnackBar(
                                      e,
                                      context: originalContext,
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Sačuvaj promjene',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );

    if (result == true) {
      await _loadMemberData();
    }
  }

  Future<void> _showDeleteProfileDialog() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani. Molimo pokušajte ponovo.',
        context: context,
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Obriši profil',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Jeste li sigurni da želite obrisati svoj profil?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Text(
                '⚠️ NEPOVRATNA AKCIJA\nOva akcija će trajno obrisati sve vaše podatke.\nOva akcija se ne može poništiti!',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Otkaži'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Obriši profil'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteProfile();
    }
  }

  Future<void> _deleteProfile() async {
    try {
      final memberProvider = Provider.of<MemberProvider>(
        context,
        listen: false,
      );

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );
      }

      await memberProvider.delete(_currentMember!.id);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );

        SnackBarUtils.showSuccessSnackBar(
          'Profil je uspješno obrisan.',
          context: context,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (context.mounted) {
        SnackBarUtils.showErrorSnackBar(e, context: context);
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    if (_currentMember == null) {
      SnackBarUtils.showErrorSnackBar(
        'Podaci o članu nisu učitani. Molimo pokušajte ponovo.',
        context: context,
      );
      return;
    }

    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    bool oldPasswordVisible = false;
    bool newPasswordVisible = false;
    bool confirmPasswordVisible = false;

    final formKey = GlobalKey<FormState>();
    String? generalError;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.lock_reset, color: Colors.white, size: 24),
                          const SizedBox(width: 12),
                          const Text(
                            'Promijeni lozinku',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (generalError != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          generalError!,
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              TextFormField(
                                controller: oldPassController,
                                obscureText: !oldPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Trenutna lozinka',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  errorMaxLines: 3,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      oldPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        oldPasswordVisible =
                                            !oldPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Unesite trenutnu lozinku'
                                    : null,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: newPassController,
                                obscureText: !newPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Nova lozinka',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  errorMaxLines: 3,
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      newPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        newPasswordVisible =
                                            !newPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Lozinka je obavezna.';
                                  }
                                  if (v.length < 8) {
                                    return 'Lozinka mora imati najmanje 8 znakova.';
                                  }
                                  if (!RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$',
                                  ).hasMatch(v)) {
                                    return 'Lozinka mora sadržavati velika i mala slova, broj i spec. znak.';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 20),

                              TextFormField(
                                controller: confirmPassController,
                                obscureText: !confirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Potvrdi novu lozinku',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  errorMaxLines: 3,
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      confirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        confirmPasswordVisible =
                                            !confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) => v != newPassController.text
                                    ? 'Lozinke se ne poklapaju'
                                    : null,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              child: const Text(
                                'Otkaži',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  try {
                                    final provider =
                                        Provider.of<MemberProvider>(
                                          context,
                                          listen: false,
                                        );

                                    await provider
                                        .changePassword(_currentMember!.id, {
                                          'OldPassword': oldPassController.text,
                                          'NewPassword': newPassController.text,
                                          'ConfirmNewPassword':
                                              confirmPassController.text,
                                        });

                                    Navigator.of(context).pop(true);
                                  } catch (e) {
                                    if (context.mounted) {
                                      setState(() {
                                        final message = e.toString();
                                        if (message.contains(
                                          'Stara lozinka nije ispravna',
                                        )) {
                                          generalError =
                                              'Stara lozinka nije ispravna.';
                                        } else if (message.contains(
                                          'Nova lozinka ne smije biti ista kao stara',
                                        )) {
                                          generalError =
                                              'Nova lozinka ne smije biti ista kao stara.';
                                        } else if (message.contains(
                                          'Lozinke se ne poklapaju',
                                        )) {
                                          generalError =
                                              'Lozinke se ne poklapaju.';
                                        } else {
                                          generalError = message.replaceFirst(
                                            'Greška: ',
                                            '',
                                          );
                                        }
                                      });

                                      Future.delayed(
                                        const Duration(seconds: 4),
                                        () {
                                          if (context.mounted) {
                                            setState(() {
                                              generalError = null;
                                            });
                                          }
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Promijeni lozinku',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
            );
          },
        );
      },
    );

    if (result == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );

          SnackBarUtils.showSuccessSnackBar(
            'Lozinka je uspješno promijenjena. Molimo prijavite se ponovo.',
            context: context,
          );
        }
      } catch (e) {
        if (context.mounted) {
          SnackBarUtils.showErrorSnackBar(e, context: context);
        }
      }
    }
  }
}
