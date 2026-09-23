import 'package:flutter/material.dart';

/// 空态。
class NewCarFollowEmptyState extends StatelessWidget {
  const NewCarFollowEmptyState({super.key, this.onCreate});

  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 88,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            Text(
              '还没有跟进档案，去建第一份吧~',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                onPressed: onCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B8CFF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  '新建跟进档案',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
