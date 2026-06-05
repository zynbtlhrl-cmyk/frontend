import 'package:flutter/material.dart';

class TableRowWidget extends StatelessWidget {
  final List<List<String>> data;

  final bool isCourse;
  final bool isVideo;

  final Function(List<String>)? onEdit;
  final Function(String)? onDelete;

  const TableRowWidget({
    super.key,
    required this.data,
    this.isCourse = false,
    this.isVideo = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: data.map((row) {
        return Card(
          child: ListTile(
            title: Text(row[1]),
            subtitle: Text(row[2]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    _showEditDialog(context, row);
                  },
                ),

                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteDialog(context, row[0]);
                  },
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ================= EDIT =================
  void _showEditDialog(BuildContext context, List<String> row) {
    final controller = TextEditingController(text: row[1]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل"),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () {
                if (onEdit != null) {
                  onEdit!([row[0], controller.text, row[2]]);
                }
                Navigator.pop(context);
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );
  }

  // ================= DELETE CONFIRM =================
  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: const Text("هل تريد حذف هذا العنصر؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 201, 200, 200),
              ),
              onPressed: () {
                if (onDelete != null) {
                  onDelete!(id);
                }
                Navigator.pop(context);
              },
              child: const Text("حذف", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
