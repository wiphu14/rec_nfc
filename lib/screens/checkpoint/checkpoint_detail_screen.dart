import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/checkpoint_model.dart';

class CheckpointDetailScreen extends StatelessWidget {
  final CheckpointModel checkpoint;

  const CheckpointDetailScreen({
    Key? key,
    required this.checkpoint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดจุดตรวจ'),
        backgroundColor: AppConfig.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppConfig.primaryColor,
                    AppConfig.secondaryColor,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sequence Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'จุดที่ ${checkpoint.sequenceOrder}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checkpoint Name
                  Text(
                    checkpoint.checkpointName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Checkpoint Code
                  Text(
                    checkpoint.checkpointCode,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (checkpoint.description != null) ...[
                    _buildSectionTitle('รายละเอียด'),
                    _buildInfoCard(
                      icon: Icons.description,
                      content: checkpoint.description!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location Detail
                  if (checkpoint.locationDetail != null) ...[
                    _buildSectionTitle('สถานที่'),
                    _buildInfoCard(
                      icon: Icons.place,
                      content: checkpoint.locationDetail!,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Requirements
                  _buildSectionTitle('ข้อกำหนด'),
                  _buildRequirementsCard(),
                  const SizedBox(height: 16),

                  // NFC Tags
                  _buildSectionTitle('NFC Tags ที่ลงทะเบียน'),
                  _buildNfcTagsCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String content}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppConfig.primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRequirementRow(
              icon: checkpoint.isRequired ? Icons.check_circle : Icons.cancel,
              label: 'บังคับตรวจ',
              value: checkpoint.isRequired ? 'ใช่' : 'ไม่',
              color: checkpoint.isRequired 
                  ? AppConfig.errorColor 
                  : AppConfig.successColor,
            ),
            const Divider(height: 24),
            _buildRequirementRow(
              icon: checkpoint.requirePhoto ? Icons.camera_alt : Icons.cancel,
              label: 'ต้องถ่ายรูป',
              value: checkpoint.requirePhoto ? 'ใช่' : 'ไม่',
              color: checkpoint.requirePhoto 
                  ? AppConfig.warningColor 
                  : AppConfig.successColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNfcTagsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.nfc, color: AppConfig.primaryColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'จำนวน ${checkpoint.nfcTagCount} Tags',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (checkpoint.nfcTags.isNotEmpty) ...[
              const Divider(height: 24),
              ...checkpoint.nfcTags.map((tag) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppConfig.successColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'monospace',
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to scan screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ฟีเจอร์กำลังพัฒนา'),
              ),
            );
          },
          icon: const Icon(Icons.nfc),
          label: const Text('เริ่มสแกน NFC'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConfig.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}