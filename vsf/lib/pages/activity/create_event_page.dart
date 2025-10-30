import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';  
import 'package:hive/hive.dart';
import '../../models/event_model.dart';
import '../../models/event_location.dart';
import '../../models/user_model.dart';

class CreateEventPage extends StatefulWidget {
	final UserModel currentUser;
	const CreateEventPage({super.key, required this.currentUser});

	@override
	State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
	final _formKey = GlobalKey<FormState>();
	final _titleController = TextEditingController();
	final _descController = TextEditingController();
	final _targetVolunteerController = TextEditingController(text: '50');
	final _feeController = TextEditingController();
	final _districtController = TextEditingController();
	final _villageController = TextEditingController();
	final _rtRwController = TextEditingController();

	String? _selectedCategory;
	String? _selectedCountry;
	String? _selectedProvince;
	String? _selectedCity;
	DateTime? _startDateTime;
	DateTime? _endDateTime;
	File? _pickedImage;

	final List<String> _categories = [
		'Pendidikan', 'Lingkungan', 'Kesehatan', 'Sosial', 'Anak-anak'
	];
	final List<String> _countries = ['Indonesia'];
	final List<String> _provinces = [
		'DKI Jakarta', 'Jawa Barat', 'Jawa Tengah', 'Jawa Timur', 'Banten'
	];
	final Map<String, List<String>> _citiesByProvince = {
		'DKI Jakarta': ['Jakarta Pusat', 'Jakarta Barat', 'Jakarta Timur', 'Jakarta Selatan', 'Jakarta Utara'],
		'Jawa Barat': ['Bandung', 'Bekasi', 'Bogor', 'Depok', 'Cimahi'],
		'Jawa Tengah': ['Semarang', 'Surakarta', 'Magelang'],
		'Jawa Timur': ['Surabaya', 'Malang', 'Kediri'],
		'Banten': ['Tangerang', 'Serang', 'Cilegon'],
	};

	Future<void> _pickImage() async {
		final picker = ImagePicker();
		final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
		if (picked != null) {
			setState(() => _pickedImage = File(picked.path));
		}
	}

	Future<void> _pickDateTime({required bool isStart}) async {
		final now = DateTime.now();
		final date = await showDatePicker(
			context: context,
			initialDate: now,
			firstDate: now,
			lastDate: DateTime(now.year + 2),
		);
		if (date == null) return;
		final time = await showTimePicker(
			context: context,
			initialTime: TimeOfDay.now(),
		);
		if (time == null) return;
		final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
		setState(() {
			if (isStart) {
				_startDateTime = dt;
			} else {
				_endDateTime = dt;
			}
		});
	}

	Future<void> _submit() async {
		if (!_formKey.currentState!.validate() || _startDateTime == null || _endDateTime == null) return;
		final eventBox = Hive.box<EventModel>('events');
		final id = DateTime.now().millisecondsSinceEpoch.toString();
		final location = EventLocation(
			country: _selectedCountry ?? '',
			province: _selectedProvince ?? '',
			city: _selectedCity ?? '',
			district: _districtController.text,
			village: _villageController.text,
			rtRw: _rtRwController.text,
			latitude: 0,
			longitude: 0,
		);
		final event = EventModel(
			id: id,
			title: _titleController.text,
			description: _descController.text,
			imageUrl: _pickedImage?.path, // Save path, or upload to server if needed
			organizerId: widget.currentUser.id,
			organizerName: widget.currentUser.fullName ?? widget.currentUser.organizationName ?? '-',
			organizerImageUrl: widget.currentUser.profileImagePath,
			location: location,
			eventStartTime: _startDateTime!,
			eventEndTime: _endDateTime!,
			targetVolunteerCount: int.tryParse(_targetVolunteerController.text) ?? 0,
			currentVolunteerCount: 0,
			participationFeeIdr: int.tryParse(_feeController.text) ?? 0,
			category: _selectedCategory ?? '',
			isActive: true,
			createdAt: DateTime.now(),
		);
		await eventBox.put(id, event);
		if (mounted) Navigator.pop(context, true);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('Daftarkan Kegiatan Baru'),
				leading: IconButton(
					icon: const Icon(Icons.arrow_back),
					onPressed: () => Navigator.pop(context),
				),
			),
			body: SingleChildScrollView(
				padding: const EdgeInsets.all(20),
				child: Form(
					key: _formKey,
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text('Judul Kegiatan'),
							const SizedBox(height: 8),
							TextFormField(
								controller: _titleController,
								decoration: const InputDecoration(
									hintText: 'Contoh: Aksi Bersih Pantai Ancol',
									border: OutlineInputBorder(),
								),
								validator: (v) => v == null || v.isEmpty ? 'Judul wajib diisi' : null,
							),
							const SizedBox(height: 16),
							const Text('Deskripsi Kegiatan'),
							const SizedBox(height: 8),
							TextFormField(
								controller: _descController,
								minLines: 3,
								maxLines: 5,
								decoration: const InputDecoration(
									hintText: 'Jelaskan tujuan dan tugas volunteer secara rinci',
									border: OutlineInputBorder(),
								),
								validator: (v) => v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
							),
							const SizedBox(height: 16),
							const Text('Unggah Gambar Kegiatan'),
							const SizedBox(height: 8),
							GestureDetector(
								onTap: _pickImage,
								child: DottedBorder(
									color: Colors.grey,
									strokeWidth: 1,
									dashPattern: const [6, 3],
									borderType: BorderType.RRect,
									radius: const Radius.circular(12),
									child: Container(
										height: 120,
										width: double.infinity,
										alignment: Alignment.center,
										child: _pickedImage == null
												? const Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey),
															SizedBox(height: 8),
															Text('Unggah file atau seret dan lepas\nPNG, JPG, GIF hingga 10MB',
																	textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
														],
													)
												: Image.file(_pickedImage!, height: 100),
									),
								),
							),
							const SizedBox(height: 16),
							const Text('Kategori'),
							const SizedBox(height: 8),
							DropdownButtonFormField<String>(
								initialValue: _selectedCategory,
								items: _categories
										.map((c) => DropdownMenuItem(value: c, child: Text(c)))
										.toList(),
								onChanged: (v) => setState(() => _selectedCategory = v),
								decoration: const InputDecoration(border: OutlineInputBorder()),
								validator: (v) => v == null ? 'Pilih kategori' : null,
							),
							const SizedBox(height: 16),
							const Text('Lokasi'),
							const SizedBox(height: 8),
							DropdownButtonFormField<String>(
								initialValue: _selectedCountry,
								items: _countries
										.map((c) => DropdownMenuItem(value: c, child: Text(c)))
										.toList(),
								onChanged: (v) => setState(() => _selectedCountry = v),
								decoration: const InputDecoration(labelText: 'Pilih Negara', border: OutlineInputBorder()),
								validator: (v) => v == null ? 'Pilih negara' : null,
							),
							const SizedBox(height: 8),
							DropdownButtonFormField<String>(
								initialValue: _selectedProvince,
								items: _provinces
										.map((p) => DropdownMenuItem(value: p, child: Text(p)))
										.toList(),
								onChanged: (v) {
									setState(() {
										_selectedProvince = v;
										_selectedCity = null;
									});
								},
								decoration: const InputDecoration(labelText: 'Pilih Provinsi', border: OutlineInputBorder()),
								validator: (v) => v == null ? 'Pilih provinsi' : null,
							),
							const SizedBox(height: 8),
							DropdownButtonFormField<String>(
								initialValue: _selectedCity,
								items: (_citiesByProvince[_selectedProvince] ?? [])
										.map((c) => DropdownMenuItem(value: c, child: Text(c)))
										.toList(),
								onChanged: (v) => setState(() => _selectedCity = v),
								decoration: const InputDecoration(labelText: 'Pilih Kota/Kabupaten', border: OutlineInputBorder()),
								validator: (v) => v == null ? 'Pilih kota/kabupaten' : null,
							),
							const SizedBox(height: 8),
							TextFormField(
								controller: _districtController,
								decoration: const InputDecoration(hintText: 'Kecamatan', border: OutlineInputBorder()),
								validator: (v) => v == null || v.isEmpty ? 'Kecamatan wajib diisi' : null,
							),
							const SizedBox(height: 8),
							TextFormField(
								controller: _villageController,
								decoration: const InputDecoration(hintText: 'Desa/Kelurahan', border: OutlineInputBorder()),
								validator: (v) => v == null || v.isEmpty ? 'Desa/Kelurahan wajib diisi' : null,
							),
							const SizedBox(height: 8),
							TextFormField(
								controller: _rtRwController,
								decoration: const InputDecoration(hintText: 'RT/RW', border: OutlineInputBorder()),
								validator: (v) => v == null || v.isEmpty ? 'RT/RW wajib diisi' : null,
							),
							const SizedBox(height: 16),
							const Text('Tanggal & Waktu Mulai'),
							const SizedBox(height: 8),
							InkWell(
								onTap: () => _pickDateTime(isStart: true),
								child: InputDecorator(
									decoration: const InputDecoration(
										border: OutlineInputBorder(),
										hintText: 'mm/dd/yyyy, --:-- --',
									),
									child: Text(_startDateTime == null
											? ''
											: '${_startDateTime!.toLocal()}'.split('.').first.replaceAll('T', ' ')),
								),
							),
							const SizedBox(height: 16),
							const Text('Tanggal & Waktu Selesai'),
							const SizedBox(height: 8),
							InkWell(
								onTap: () => _pickDateTime(isStart: false),
								child: InputDecorator(
									decoration: const InputDecoration(
										border: OutlineInputBorder(),
										hintText: 'mm/dd/yyyy, --:-- --',
									),
									child: Text(_endDateTime == null
											? ''
											: '${_endDateTime!.toLocal()}'.split('.').first.replaceAll('T', ' ')),
								),
							),
							const SizedBox(height: 16),
							const Text('Target Jumlah Volunteer'),
							const SizedBox(height: 8),
							TextFormField(
								controller: _targetVolunteerController,
								keyboardType: TextInputType.number,
								decoration: const InputDecoration(
									prefixIcon: Icon(Icons.people),
									border: OutlineInputBorder(),
								),
								validator: (v) => v == null || v.isEmpty ? 'Target volunteer wajib diisi' : null,
							),
							const SizedBox(height: 16),
							const Text('Harga Partisipasi (Rp)'),
							const SizedBox(height: 8),
							TextFormField(
								controller: _feeController,
								keyboardType: TextInputType.number,
								decoration: const InputDecoration(
									prefixText: 'Rp ',
									hintText: 'Kosongkan jika gratis',
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 24),
							SizedBox(
								width: double.infinity,
								child: ElevatedButton(
									onPressed: _submit,
									style: ElevatedButton.styleFrom(
										backgroundColor: Colors.blue[600],
										foregroundColor: Colors.white,
										padding: const EdgeInsets.symmetric(vertical: 16),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(12),
										),
									),
									child: const Text('Daftarkan Kegiatan', style: TextStyle(fontWeight: FontWeight.bold)),
								),
							),
						],
					),
				),
			),
		);
	}
}

// DottedBorder widget (simple fallback if not installed)
class DottedBorder extends StatelessWidget {
	final Widget child;
	final Color color;
	final double strokeWidth;
	final List<double> dashPattern;
	final BorderType borderType;
	final Radius radius;
	const DottedBorder({required this.child, this.color = Colors.grey, this.strokeWidth = 1, this.dashPattern = const [6, 3], this.borderType = BorderType.RRect, this.radius = const Radius.circular(12), super.key});
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.all(radius),
				border: Border.all(color: color, width: strokeWidth, style: BorderStyle.solid),
			),
			child: child,
		);
	}
}

enum BorderType { RRect }
