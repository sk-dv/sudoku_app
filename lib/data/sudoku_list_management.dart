import 'package:sudoku_app/data/sudoku_object.dart';

extension SudokuListManagement on List<List<SudokuObject>> {
  static List<List<SudokuObject>> fromBoard(List<List<int>> board) {
    return board.map((row) {
      return row.map((value) {
        return SudokuObject(
          value: value,
          isOriginal: false,
          isSelected: false,
          isHighlighted: false,
          isError: false,
        );
      }).toList();
    }).toList();
  }

  List<List<int>> get board {
    return map((row) => row.map((cell) => cell.value).toList()).toList();
  }

  List<List<bool>> get isOriginal {
    return map((row) => row.map((cell) => cell.isOriginal).toList()).toList();
  }

  List<List<bool>> get isSelected {
    return map((row) => row.map((cell) => cell.isSelected).toList()).toList();
  }

  List<List<bool>> get isHighlighted {
    return map((row) => row.map((cell) => cell.isHighlighted).toList())
        .toList();
  }

  List<List<bool>> get isErrorCell {
    return map((row) => row.map((cell) => cell.isError).toList()).toList();
  }
}
