import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/log_harian_teknis_controller.dart';
import '../model/log_harian_teknis_model.dart'; 

class LogHarianTeknisView extends StatelessWidget {
  LogHarianTeknisView({super.key});

  static const Color _primary = Color(0xFF1A3A6B);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(LogHarianTeknisController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _primary),
        title: const Text(
          'Log Harian Teknis', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)
        ), 
      ),
      body: Column(
        children: [
          // ── FORM INPUT SECTION ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Form(
              key: c.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Row(
                    children: [
                      Icon(c.isEditing.value ? Icons.edit_note_outlined : Icons.add_circle_outline, color: _primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        c.isEditing.value ? 'Ubah Log Harian' : 'Tambah Log Harian Baru', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primary)
                      ),
                      const Spacer(),
                      if (c.isEditing.value)
                        InkWell(
                          onTap: c.cancelEdit,
                          child: const Text('Batal', style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                        )
                    ],
                  )),
                  const SizedBox(height: 16),
                  
                  // Date Picker
                  Obx(() => GestureDetector(
                    onTap: () => c.pickDate(context),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 18, color: _primary),
                          const SizedBox(width: 10),
                          Text(
                            '${c.selectedDate.value.day}/${c.selectedDate.value.month}/${c.selectedDate.value.year}',
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  )),
                  
                  _buildTextField('Keterangan', c.keteranganCtrl, req: true, maxLines: 3),
                  
                  const SizedBox(height: 4),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: c.isSubmitting.value ? null : c.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: c.isSubmitting.value
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(c.isEditing.value ? 'Simpan Perubahan' : 'Simpan Log', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          // ── LIST LOG HARIAN SECTION ──
          Expanded(
            child: Obx(() {
              if (c.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history_outlined, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 12),
                      Text('Belum ada log harian yang dicatat', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ],
                  )
                );
              }
              
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: c.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final log = c.items[i];
                  final isSynced = log.syncStatus == LogHarianSyncStatus.synced;
                  final formattedDate = '${log.tanggal.day}/${log.tanggal.month}/${log.tanggal.year}';

                  return Dismissible(
                    key: Key(log.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
                    ),
                    onDismissed: (direction) => c.deleteLog(log.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.engineering_outlined, color: _primary, size: 22),
                        ),
                        // Replace lost `kegiatan` field visually with the Date
                        title: Text('Log: $formattedDate', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _primary)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              log.keterangan.isNotEmpty ? log.keterangan : '-',
                              style: const TextStyle(fontSize: 12, color: Colors.black87), 
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined, size: 12, color: isSynced ? Colors.green : Colors.orange),
                                const SizedBox(width: 4),
                                Text(isSynced ? 'Synced' : 'Local', style: TextStyle(fontSize: 10, color: isSynced ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
                              onPressed: () => c.prepareUpdate(log),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool req = true, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
      ),
    );
  }
}