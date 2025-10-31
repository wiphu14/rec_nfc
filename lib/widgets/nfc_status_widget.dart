import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_config.dart';
import '../providers/nfc_provider.dart';

class NfcStatusWidget extends StatelessWidget {
  const NfcStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NfcProvider>(
      builder: (context, nfcProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: nfcProvider.isAvailable
                ? AppConfig.successColor.withValues(alpha: 0.1)
                : AppConfig.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: nfcProvider.isAvailable
                  ? AppConfig.successColor
                  : AppConfig.errorColor,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.nfc,
                color: nfcProvider.isAvailable
                    ? AppConfig.successColor
                    : AppConfig.errorColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  nfcProvider.isAvailable
                      ? 'NFC พร้อมใช้งาน'
                      : 'NFC ไม่พร้อมใช้งาน',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: nfcProvider.isAvailable
                        ? AppConfig.successColor
                        : AppConfig.errorColor,
                  ),
                ),
              ),
              if (!nfcProvider.isAvailable)
                TextButton(
                  onPressed: () {
                    nfcProvider.checkNfcAvailability();
                  },
                  child: const Text('ตรวจสอบ'),
                ),
            ],
          ),
        );
      },
    );
  }
}