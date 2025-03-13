class DayCheckItem {
  final String dayLabel;
  final int streakValue; // "Hôm nay", "Ngày 2", ...
  final int reward;         // Số điểm hiển thị, ví dụ +100
  bool isCheckedIn;         // Đã điểm danh chưa

  DayCheckItem({
    required this.dayLabel,
    required this.streakValue,
    required this.reward,
    this.isCheckedIn = false,
  });
}
