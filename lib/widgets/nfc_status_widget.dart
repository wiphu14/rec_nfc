import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/nfc_provider.dart';

class NfcStatusWidget extends StatelessWidget {
  const NfcStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProvider>(
      builder: (context, nfcProvider, child) {
        // ✅ เปลี่ยนจาก isAvailable เป็น isNfcAvailable
        if (!nfcProvider.isNfcAvailable) {
          return Card(
            color: Colors.red[50],
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.nfc_outlined, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '❌ อุปกรณ์นี้ไม่รองรับ NFC',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ✅ เปลี่ยนจาก isAvailable เป็น isNfcAvailable
        return Card(
          color: nfcProvider.isNfcAvailable ? Colors.green[50] : Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(
                  Icons.nfc,
                  color: nfcProvider.isNfcAvailable ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nfcProvider.isNfcAvailable 
                        ? '✅ NFC พร้อมใช้งาน' 
                        : '⚪ กำลังตรวจสอบ NFC...',
                    style: TextStyle(
                      color: nfcProvider.isNfcAvailable ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}