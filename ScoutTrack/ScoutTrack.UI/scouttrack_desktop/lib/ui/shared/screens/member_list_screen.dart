import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scouttrack_desktop/ui/shared/layouts/master_screen.dart';
import 'package:scouttrack_desktop/ui/shared/screens/member_details_screen.dart';
import 'package:scouttrack_desktop/models/member.dart';
import 'package:scouttrack_desktop/models/search_result.dart';
import 'package:scouttrack_desktop/models/city.dart';
import 'package:scouttrack_desktop/models/troop.dart';
import 'package:scouttrack_desktop/providers/auth_provider.dart';
import 'package:scouttrack_desktop/providers/member_provider.dart';
import 'package:scouttrack_desktop/providers/city_provider.dart';
import 'package:scouttrack_desktop/providers/troop_provider.dart';
import 'package:scouttrack_desktop/utils/date_utils.dart';
import 'package:scouttrack_desktop/utils/error_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/image_utils.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/date_picker_utils.dart';

import 'package:scouttrack_desktop/ui/shared/widgets/ui_components.dart';
import 'package:scouttrack_desktop/ui/shared/widgets/pagination_controls.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:scouttrack_desktop/utils/pdf_report_utils.dart';

class MemberListScreen extends StatefulWidget {
  final int? initialTroopId;

  const MemberListScreen({super.key, this.initialTroopId});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  SearchResult<Member>? _members;
  bool _loading = false;
  String? _error;
  String? _role;
  int? _loggedInUserId;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  int? _selectedCityId;
  int? _selectedTroopId;
  int? _selectedGender;
  String? _selectedSort;
  bool _showOnlyMyMembers = false;
  List<City> _cities = [];
  List<Troop> _troops = [];

  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late MemberProvider _memberProvider;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        _memberProvider = MemberProvider(authProvider);

        if (_role == null) {
          _loadInitialData();
        }
      }
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _verticalScrollController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      if (!mounted) return;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isLoggedIn) {
        print('User not authenticated, skipping data load');
        return;
      }

      final role = await authProvider.getUserRole();
      final userId = await authProvider.getUserIdFromToken();

      if (!mounted) return;

      setState(() {
        _role = role;
        _loggedInUserId = userId;
      });

      final cityProvider = CityProvider(authProvider);
      final troopProvider = TroopProvider(authProvider);
      var filter = {"RetrieveAll": true};
      final cityResult = await cityProvider.get(filter: filter);
      final troopResult = await troopProvider.get(filter: filter);

      if (!mounted) return;

      setState(() {
        _cities = cityResult.items ?? [];
        _troops = troopResult.items ?? [];

        if (widget.initialTroopId != null) {
          final troopExists = _troops.any(
            (troop) => troop.id == widget.initialTroopId,
          );
          if (troopExists) {
            _selectedTroopId = widget.initialTroopId;
            _showOnlyMyMembers = false;
          }
        }
      });
      await _fetchMembers();
    } catch (e) {
      print('Error in _loadInitialData: $e');
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        currentPage = 1;
      });
      _fetchMembers();
    });
  }

  Future<void> _fetchMembers({int? page}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      int? troopIdForFilter = _selectedTroopId;
      if (_showOnlyMyMembers && _role == 'Troop' && _loggedInUserId != null) {
        troopIdForFilter = _loggedInUserId;
      }

      var filter = {
        if (searchController.text.isNotEmpty) "FTS": searchController.text,
        if (_selectedCityId != null) "CityId": _selectedCityId,
        if (troopIdForFilter != null) "TroopId": troopIdForFilter,
        if (_selectedGender != null) "Gender": _selectedGender,
        if (_selectedSort != null) "OrderBy": _selectedSort,
        "Page": ((page ?? currentPage) - 1),
        "PageSize": pageSize,
        "IncludeTotalCount": true,
      };
      var result = await _memberProvider.get(filter: filter);

      setState(() {
        _members = result;
        currentPage = page ?? currentPage;
        totalPages = ((result.totalCount ?? 0) / pageSize).ceil();
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _members = null;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      role: _role ?? '',
      selectedMenu: 'Članovi',
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        hintText: 'Pretraži članove...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedCityId,
                      decoration: const InputDecoration(
                        labelText: 'Grad',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedCityId = value;
                          currentPage = 1;
                        });
                        _fetchMembers();
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Svi gradovi"),
                        ),
                        ..._cities.map(
                          (city) => DropdownMenuItem(
                            value: city.id,
                            child: Text(city.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedTroopId,
                      decoration: const InputDecoration(
                        labelText: 'Odred',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedTroopId = value;
                          if (value != null) {
                            _showOnlyMyMembers = false;
                          }
                          currentPage = 1;
                        });
                        _fetchMembers();
                      },
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text("Svi odredi"),
                        ),
                        ..._troops.map(
                          (troop) => DropdownMenuItem(
                            value: troop.id,
                            child: Text(troop.name),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<int?>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Spol',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                          currentPage = 1;
                        });
                        _fetchMembers();
                      },
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Svi')),
                        DropdownMenuItem(value: 0, child: Text('Muški')),
                        DropdownMenuItem(value: 1, child: Text('Ženski')),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: DropdownButtonFormField<String?>(
                      value: _selectedSort,
                      decoration: const InputDecoration(
                        labelText: 'Sortiraj',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedSort = value;
                          currentPage = 1;
                        });
                        _fetchMembers();
                      },
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Bez sortiranja'),
                        ),
                        DropdownMenuItem(
                          value: 'firstName',
                          child: Text('Ime (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-firstName',
                          child: Text('Ime (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'lastName',
                          child: Text('Prezime (A-Ž)'),
                        ),
                        DropdownMenuItem(
                          value: '-lastName',
                          child: Text('Prezime (Ž-A)'),
                        ),
                        DropdownMenuItem(
                          value: 'birthDate',
                          child: Text('Datum rođenja (najstariji)'),
                        ),
                        DropdownMenuItem(
                          value: '-birthDate',
                          child: Text('Datum rođenja (najnoviji)'),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_role == 'Admin' || _role == 'Troop')
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _loading ? null : _generateReport,
                          icon: _loading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf),
                          label: Text(
                            _loading ? 'Generiranje...' : 'Generiši izvještaj',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _onAddMember,
                          icon: const Icon(Icons.add),
                          label: Text(
                            'Dodaj novog člana',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            minimumSize: const Size(0, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_role == 'Troop') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _showOnlyMyMembers,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyMyMembers = value ?? false;
                        if (_showOnlyMyMembers) {
                          _selectedTroopId = _loggedInUserId;
                        } else {
                          _selectedTroopId = null;
                        }
                        currentPage = 1;
                      });
                      _fetchMembers();
                    },
                  ),
                  const Text(
                    'Prikaži samo moje članove',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            if (_members != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade700,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prikazano ${_members!.items?.length ?? 0} od ukupno ${_members!.totalCount ?? 0} članova',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildResultView()),
                  const SizedBox(height: 4),
                  PaginationControls(
                    currentPage: currentPage,
                    totalPages: totalPages,
                    totalCount: _members?.totalCount ?? 0,
                    onPageChanged: (page) => _fetchMembers(page: page),
                  ),
                  if (_shouldShowNotificationButton()) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _onSendNotification,
                        icon: const Icon(Icons.notifications),
                        label: const Text(
                          'Pošalji obavještenje prikazanim članovima',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          minimumSize: const Size(0, 48),
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddMember() {
    _showMemberDialog();
  }

  void _onEditMember(Member member) {
    _showMemberDialog(member: member);
  }

  Future<void> _onDeleteMember(Member member) async {
    final confirm = await UIComponents.showDeleteConfirmationDialog(
      context: context,
      itemName: '${member.firstName} ${member.lastName}',
      itemType: 'člana',
    );
    if (confirm) {
      try {
        await _memberProvider.delete(member.id);

        final currentItemsOnPage = _members?.items?.length ?? 0;
        final newTotalCount = (_members?.totalCount ?? 0) - 1;
        final newTotalPages = (newTotalCount / pageSize).ceil();

        if (currentItemsOnPage == 1 && currentPage > 1) {
          await _fetchMembers(page: currentPage - 1);
        } else {
          await _fetchMembers();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Član ${member.firstName} ${member.lastName} je obrisan.',
            ),
          ),
        );
      } catch (e) {
        showErrorSnackbar(context, e);
      }
    }
  }

  void _onViewMember(Member member) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MemberDetailsScreen(
          member: member,
          role: _role ?? '',
          loggedInUserId: _loggedInUserId ?? 0,
          selectedMenu: 'Članovi',
        ),
      ),
    );
  }

  Future<void> _showMemberDialog({Member? member}) async {
    final isEdit = member != null;
    final _formKey = GlobalKey<FormState>();
    final TextEditingController firstNameController = TextEditingController(
      text: member?.firstName ?? '',
    );
    final TextEditingController lastNameController = TextEditingController(
      text: member?.lastName ?? '',
    );
    final TextEditingController usernameController = TextEditingController(
      text: member?.username ?? '',
    );
    final TextEditingController emailController = TextEditingController(
      text: member?.email ?? '',
    );
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final TextEditingController contactPhoneController = TextEditingController(
      text: member?.contactPhone ?? '',
    );
    final TextEditingController birthDateController = TextEditingController(
      text: member?.birthDate != null ? formatDate(member!.birthDate) : '',
    );

    bool passwordVisible = false;
    bool confirmPasswordVisible = false;

    int? selectedCityId = member?.cityId;
    int? selectedTroopId =
        member?.troopId ?? (_role == 'Troop' ? _loggedInUserId : null);
    int? selectedGender = member?.gender;
    Uint8List? _selectedImageBytes;
    File? _selectedImageFile;
    bool _isImageLoading = false;
    String? _profilePictureUrl = member?.profilePictureUrl;

    Future<void> _selectBirthDate(StateSetter setState) async {
      final DateTime? picked = await DatePickerUtils.showDatePickerDialog(
        context: context,
        initialDate: member?.birthDate ?? DateTime.now(),
        minDate: DateTime(1900),
        maxDate: DateTime.now(),
        title: 'Odaberite datum rođenja',
        controller: birthDateController,
      );
      if (picked != null) {
        setState(() {
          birthDateController.text = formatDate(picked);
        });
      }
    }

    Future<void> _pickImage(StateSetter setState) async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final compressedBytes = await ImageUtils.compressImage(bytes);
        setState(() {
          _selectedImageBytes = compressedBytes;
          _selectedImageFile = File(pickedFile.path);
        });
      }
    }

    Future<void> _uploadImage(StateSetter setState, int memberId) async {
      try {
        setState(() {
          _isImageLoading = true;
        });
        final memberProvider = Provider.of<MemberProvider>(
          context,
          listen: false,
        );
        final updatedMember = await memberProvider.updateProfilePicture(
          memberId,
          _selectedImageFile,
        );
        setState(() {
          _profilePictureUrl = updatedMember.profilePictureUrl;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Slika je uspješno promijenjena.')),
          );
        }
      } catch (e) {
        if (context.mounted) showErrorSnackbar(context, e);
      } finally {
        setState(() {
          _isImageLoading = false;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 600,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isEdit ? 'Uredi člana' : 'Dodaj člana',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!isEdit) ...[
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: _selectedImageBytes != null
                                      ? Image.memory(
                                          _selectedImageBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : (_profilePictureUrl != null &&
                                                _profilePictureUrl!.isNotEmpty
                                            ? Image.network(
                                                _profilePictureUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return const Center(
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 50,
                                                        ),
                                                      );
                                                    },
                                              )
                                            : const Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 50,
                                                ),
                                              )),
                                ),
                              ),
                              if (_selectedImageBytes != null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedImageBytes = null;
                                        _selectedImageFile = null;
                                        _profilePictureUrl = '';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.image, size: 16),
                          label: const Text('Odaberi profilnu fotografiju'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(160, 40),
                          ),
                          onPressed: () => _pickImage(setState),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Ime *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ime je obavezan.';
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Prezime *',
                                errorMaxLines: 3,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Prezime je obavezan.';
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
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: usernameController,
                              decoration: const InputDecoration(
                                labelText: 'Korisničko ime *',
                                errorMaxLines: 3,
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
                                  return 'Korisničko ime može sadržavati samo slova, brojeve, tačke, donje crte ili crtice.';
                                }
                                return null;
                              },
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'E-mail *',
                                errorMaxLines: 3,
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
                            const SizedBox(height: 12),
                            if (!isEdit) ...[
                              TextFormField(
                                controller: passwordController,
                                obscureText: !passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Lozinka *',
                                  errorMaxLines: 3,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Lozinka je obavezna.';
                                  }
                                  if (value.length < 8) {
                                    return 'Lozinka mora imati najmanje 8 znakova.';
                                  }
                                  if (!RegExp(
                                    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).+$',
                                  ).hasMatch(value)) {
                                    return 'Lozinka mora sadržavati velika i mala slova, broj i spec. znak.';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (!isEdit) ...[
                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: !confirmPasswordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Potvrdi lozinku *',
                                  errorMaxLines: 3,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      confirmPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        confirmPasswordVisible =
                                            !confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                validator: (v) => v != passwordController.text
                                    ? 'Lozinke se ne poklapaju'
                                    : null,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                              const SizedBox(height: 12),
                            ],
                            TextFormField(
                              controller: contactPhoneController,
                              decoration: const InputDecoration(
                                labelText: 'Telefon *',
                                errorMaxLines: 3,
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
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _selectBirthDate(setState),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: birthDateController,
                                  decoration: const InputDecoration(
                                    labelText: 'Datum rođenja *',
                                    errorMaxLines: 3,
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  validator: (value) =>
                                      DatePickerUtils.validateRequiredDate(
                                        value,
                                      ),
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Spol *',
                                errorMaxLines: 3,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 0,
                                  child: Text('Muški'),
                                ),
                                DropdownMenuItem(
                                  value: 1,
                                  child: Text('Ženski'),
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
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<int>(
                              value: selectedCityId,
                              decoration: const InputDecoration(
                                labelText: 'Grad *',
                                errorMaxLines: 3,
                              ),
                              items: _cities
                                  .map(
                                    (c) => DropdownMenuItem<int>(
                                      value: c.id,
                                      child: Text(c.name),
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
                            ),
                            const SizedBox(height: 12),
                            if (_role == 'Admin' && !isEdit) ...[
                              DropdownButtonFormField<int>(
                                value: selectedTroopId,
                                decoration: const InputDecoration(
                                  labelText: 'Odred *',
                                  errorMaxLines: 3,
                                ),
                                items: _troops
                                    .map(
                                      (t) => DropdownMenuItem<int>(
                                        value: t.id,
                                        child: Text(t.name),
                                      ),
                                    )
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Odred je obavezan.';
                                  }
                                  return null;
                                },
                                onChanged: (val) {
                                  setState(() {
                                    selectedTroopId = val;
                                  });
                                },
                              ),
                            ],
                            if (_role == 'Troop' && !isEdit) ...[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.group,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Odred: ${_getTroopName(_loggedInUserId)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Otkaži'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                try {
                                  final requestBody = {
                                    "firstName": firstNameController.text
                                        .trim(),
                                    "lastName": lastNameController.text.trim(),
                                    "username": usernameController.text.trim(),
                                    "email": emailController.text.trim(),
                                    if (!isEdit)
                                      "password": passwordController.text
                                          .trim(),
                                    if (!isEdit)
                                      "passwordConfirm":
                                          confirmPasswordController.text.trim(),
                                    "contactPhone": contactPhoneController.text
                                        .trim(),
                                    "birthDate": parseDate(
                                      birthDateController.text,
                                    ).toIso8601String(),
                                    "gender": selectedGender,
                                    "cityId": selectedCityId,
                                    "troopId": _role == 'Admin'
                                        ? selectedTroopId
                                        : _loggedInUserId,
                                  };
                                  if (isEdit) {
                                    await _memberProvider.update(
                                      member!.id,
                                      requestBody,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Član "${firstNameController.text} ${lastNameController.text}" je ažuriran.',
                                        ),
                                      ),
                                    );
                                    await _fetchMembers(page: currentPage);
                                  } else {
                                    await _memberProvider.insert(requestBody);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Član je dodan.'),
                                      ),
                                    );
                                    final newTotalCount =
                                        (_members?.totalCount ?? 0) + 1;
                                    final newTotalPages =
                                        (newTotalCount / pageSize).ceil();
                                    await _fetchMembers(page: newTotalPages);
                                  }
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  showErrorSnackbar(context, e);
                                }
                              }
                            },
                            child: Text(isEdit ? 'Sačuvaj' : 'Dodaj'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getTroopName(int? troopId) {
    if (troopId == null) return 'Nepoznat odred';
    try {
      return _troops
          .firstWhere(
            (t) => t.id == troopId,
            orElse: () => Troop(
              name: 'Nepoznat odred',
              createdAt: DateTime.now(),
              foundingDate: DateTime.now(),
            ),
          )
          .name;
    } catch (e) {
      return 'Nepoznat odred';
    }
  }

  bool _shouldShowNotificationButton() {
    return _showOnlyMyMembers ||
        _selectedTroopId == _loggedInUserId ||
        _role == 'Admin';
  }

  void _onSendNotification() {
    int? troopIdForNotification = _selectedTroopId;
    if (_showOnlyMyMembers && _role == 'Troop' && _loggedInUserId != null) {
      troopIdForNotification = _loggedInUserId;
    }

    String troopName = _getTroopName(troopIdForNotification);
    int memberCount = _members?.items?.length ?? 0;

    if (memberCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nema članova za slanje obavještenja.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Slanje obavještenja'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Želite li poslati obavještenje svim prikazanim članovima?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Odred: $troopName',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Broj članova: $memberCount'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Odustani'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement notification sending logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Obavještenje je poslano $memberCount članovima odreda "$troopName".',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('Pošalji obavještenje'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateReport() async {
    try {
      setState(() {
        _loading = true;
      });

      int? troopIdForFilter = _selectedTroopId;
      if (_showOnlyMyMembers && _role == 'Troop' && _loggedInUserId != null) {
        troopIdForFilter = _loggedInUserId;
      }

      var filter = {
        if (searchController.text.isNotEmpty) "FTS": searchController.text,
        if (_selectedCityId != null) "CityId": _selectedCityId,
        if (troopIdForFilter != null) "TroopId": troopIdForFilter,
        if (_selectedGender != null) "Gender": _selectedGender,
        if (_selectedSort != null) "OrderBy": _selectedSort,
        "RetrieveAll": true,
        "IncludeTotalCount": true,
      };

      if (_selectedCityId != null) {
        final selectedCity = _cities.firstWhere((c) => c.id == _selectedCityId);
        filter["CityName"] = selectedCity.name;
      }

      if (troopIdForFilter != null) {
        final selectedTroop = _troops.firstWhere((t) => t.id == troopIdForFilter);
        filter["TroopName"] = selectedTroop.name;
      }

      if (_selectedGender != null) {
        filter["GenderText"] = _selectedGender == 0 ? 'Muski' : 'Zenski';
      }

      var result = await _memberProvider.get(filter: filter);

      if (result.items != null && result.items!.isNotEmpty) {
        final filePath = await PdfReportUtils.generateMemberReport(
          result.items!,
          filters: filter,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PDF izvještaj je uspješno generiran!'),
                  const SizedBox(height: 4),
                  Text(
                    'Datoteka spremljena u: $filePath',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nema podataka za generiranje izvještaja.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Widget _buildResultView() {
    if (_loading && _members == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(
          'Greška pri učitavanju: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_members == null ||
        _members!.items == null ||
        _members!.items!.isEmpty) {
      return const Center(
        child: Text(
          'Nema dostupnih članova',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        trackVisibility: true,
        thickness: 8,
        radius: const Radius.circular(4),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1200),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.grey.shade100,
                ),
                columnSpacing: 32,
                columns: const [
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('IME'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('PREZIME'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('KORISNIČKO IME'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('GRAD'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('ODRED'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('DATUM ROĐENJA'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('SPOL'),
                    ),
                  ),
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('AKTIVAN'),
                    ),
                  ),
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('')),
                  DataColumn(label: Text('')),
                ],
                rows: _members!.items!.map((member) {
                  final canEditOrDelete =
                      _role == 'Admin' ||
                      (_role == 'Troop' && _loggedInUserId == member.troopId);
                  return DataRow(
                    cells: [
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(member.firstName),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(member.lastName),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(member.username),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(member.cityName),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(_getTroopName(member.troopId)),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(formatDate(member.birthDate)),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(member.gender == 0 ? 'Muški' : 'Ženski'),
                        ),
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: member.isActive
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.close, color: Colors.red),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(
                            Icons.visibility,
                            color: Colors.grey,
                          ),
                          tooltip: 'Detalji',
                          onPressed: () => _onViewMember(member),
                        ),
                      ),
                      DataCell(
                        canEditOrDelete
                            ? IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Uredi',
                                onPressed: () => _onEditMember(member),
                              )
                            : const SizedBox(),
                      ),
                      DataCell(
                        canEditOrDelete
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                tooltip: 'Obriši',
                                onPressed: () => _onDeleteMember(member),
                              )
                            : const SizedBox(),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
