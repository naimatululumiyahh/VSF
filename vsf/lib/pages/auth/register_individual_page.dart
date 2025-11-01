import 'dart:async';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/user_model.dart';
import '../../services/serpapi_service.dart';
import '../../config/secrets_example.dart' as secrets_example; // copy and create lib/config/secrets.dart locally and set SERPAPI_KEY

class RegisterIndividualPage extends StatefulWidget {
  const RegisterIndividualPage({super.key});

  @override
  State<RegisterIndividualPage> createState() => _RegisterIndividualPageState();
}

class _RegisterIndividualPageState extends State<RegisterIndividualPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Address + SerpApi
  final _addressController = TextEditingController();
  List<Map<String, dynamic>> _addressSuggestions = [];
  bool _isSearchingAddress = false;
  Timer? _addressDebounce;
  LatLng? _selectedLocation; // preview coordinate from suggestions

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _addressDebounce?.cancel();
    super.dispose();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ===== SerpApi address helpers =====
  void _onAddressChanged(String v) {
    _addressDebounce?.cancel();
    _addressDebounce = Timer(const Duration(milliseconds: 400), () {
      if (v.trim().isNotEmpty) _searchAddress(v.trim());
    });
  }

  Future<void> _searchAddress(String query) async {
    setState(() {
      _isSearchingAddress = true;
      _addressSuggestions = [];
    });
    try {
      final apiKey = secrets_example.SERPAPI_KEY;
      final results = await SerpApiService.instance.autocomplete(query, apiKey);
      setState(() {
        _addressSuggestions = results;
      });
    } catch (e) {
      // ignore errors silently for UX; optionally show message
      print('SerpApi error: $e');
    } finally {
      if (mounted) setState(() => _isSearchingAddress = false);
    }
  }

  Future<void> _selectAddressSuggestion(Map<String, dynamic> item) async {
    // item may contain description, lat/lng, or place_id
    final desc = item['description'] ?? item['formatted_address'] ?? item['title'] ?? '';
    setState(() {
      _addressController.text = desc;
      _addressSuggestions = [];
    });

    double? lat = item['lat'] is num ? (item['lat'] as num).toDouble() : null;
    double? lng = item['lng'] is num ? (item['lng'] as num).toDouble() : null;

    if (lat != null && lng != null) {
      setState(() => _selectedLocation = LatLng(lat, lng));
      return;
    }

    // fallback: if SerpApi returned a place_id, try to fetch details
    final placeId = item['place_id'] ?? item['placeid'] ?? item['place_id_token'];
    if (placeId != null) {
      try {
        final apiKey = secrets_example.SERPAPI_KEY;
        final details = await SerpApiService.instance.placeDetails(placeId: placeId.toString(), apiKey: apiKey);
        if (details != null) {
          // try to extract geometry
          Map<String, dynamic>? placeResult;
          if (details.containsKey('place_result')) placeResult = Map<String, dynamic>.from(details['place_result']);
          if (placeResult != null && placeResult['geometry'] != null && placeResult['geometry']['location'] != null) {
            final loc = placeResult['geometry']['location'];
            final dlat = loc['lat'];
            final dlng = loc['lng'];
            if (dlat != null && dlng != null) {
              setState(() => _selectedLocation = LatLng((dlat as num).toDouble(), (dlng as num).toDouble()));
            }
          }
        }
      } catch (e) {
        print('Error fetching place details: $e');
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userBox = Hive.box<UserModel>('users');
      final email = _emailController.text.trim().toLowerCase();

      // Check email sudah terdaftar
      for (var user in userBox.values) {
        if (user.email.toLowerCase() == email) {
          _showError('Email sudah terdaftar');
          return;
        }
      }

      // Buat user baru
      final newUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        passwordHash: _hashPassword(_passwordController.text),
        userType: UserType.individual,
        fullName: _nameController.text.trim(),
        nik: _nikController.text.trim(),
      );

      await userBox.add(newUser);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buat Akun Baru',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
        
                // Nama Pengguna
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Pengguna',
                    hintText: 'Masukkan nama pengguna Anda',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Nama minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                // Alamat (ketik untuk cari lokasi)
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Alamat (opsional)',
                    hintText: 'Ketik alamat, pilih dari saran',
                    prefixIcon: const Icon(Icons.place_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: _isSearchingAddress ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2)),
                    ) : null,
                  ),
                  onChanged: _onAddressChanged,
                ),
                if (_addressSuggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _addressSuggestions.length,
                      itemBuilder: (context, i) {
                        final item = _addressSuggestions[i];
                        final desc = item['description'] ?? item['formatted_address'] ?? item['title'] ?? '';
                        return ListTile(
                          dense: true,
                          title: Text(desc),
                          onTap: () => _selectAddressSuggestion(item),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                // Map preview (jika koordinat tersedia)
                if (_selectedLocation != null)
                  Container(
                    height: 160,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation ?? const LatLng(-6.200000, 106.816666),
                          zoom: 16,
                        ),
                        markers: _selectedLocation != null ? {
                          Marker(markerId: const MarkerId('sel'), position: _selectedLocation!),
                        } : {},
                        myLocationEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (_) {},
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Alamat Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Alamat Email',
                    hintText: 'contoh@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // NIK
                TextFormField(
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: InputDecoration(
                    labelText: 'Nomor Induk Kependudukan (NIK)',
                    hintText: 'Masukkan 16 digit NIK Anda',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIK tidak boleh kosong';
                    }
                    if (value.length != 16) {
                      return 'NIK harus 16 digit';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'NIK hanya boleh angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kata Sandi
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi',
                    hintText: 'Masukkan kata sandi',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Ulangi Kata Sandi
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Ulangi Kata Sandi',
                    hintText: 'Ulangi kata sandi',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi password tidak boleh kosong';
                    }
                    if (value != _passwordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Masuk di sini',
                        style: TextStyle(
                          color: Colors.blue[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}