import 'package:equatable/equatable.dart';

class SudokuObject extends Equatable {
  final int value;
  final bool isOriginal;
  final bool isSelected;
  final bool isHighlighted;
  final bool isError;

  const SudokuObject({
    required this.value,
    required this.isOriginal,
    required this.isSelected,
    required this.isHighlighted,
    required this.isError,
  });

  SudokuObject copy({
    int? value,
    bool? isOriginal,
    bool? isSelected,
    bool? isHighlighted,
    bool? isError,
  }) {
    return SudokuObject(
      value: value ?? this.value,
      isOriginal: isOriginal ?? this.isOriginal,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object> get props =>
      [value, isOriginal, isSelected, isHighlighted, isError];
}
