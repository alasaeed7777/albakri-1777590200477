```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ø­Ø§Ø³Ø¨Ù',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF1E88E5),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      themeMode: ThemeMode.system,
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _isNewOperation = true;
  bool _hasDecimal = false;

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_isNewOperation) {
        _display = digit;
        _isNewOperation = false;
        _hasDecimal = false;
      } else {
        if (_display.length < 15) {
          _display += digit;
        }
      }
    });
  }

  void _onDecimalPressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (!_hasDecimal) {
        if (_isNewOperation) {
          _display = '0.';
          _isNewOperation = false;
        } else {
          _display += '.';
        }
        _hasDecimal = true;
      }
    });
  }

  void _onOperatorPressed(String operator) {
    HapticFeedback.mediumImpact();
    setState(() {
      if (_operator != null && !_isNewOperation) {
        _calculateResult();
      }
      _firstOperand = double.parse(_display);
      _operator = operator;
      _expression = '${_formatNumber(_firstOperand!)} $operator';
      _isNewOperation = true;
      _hasDecimal = false;
    });
  }

  void _onEqualsPressed() {
    HapticFeedback.heavyImpact();
    setState(() {
      if (_operator != null) {
        _calculateResult();
        _expression = '';
        _operator = null;
        _firstOperand = null;
      }
    });
  }

  void _calculateResult() {
    final double secondOperand = double.parse(_display);
    double result = 0;
    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case 'Ã':
        result = _firstOperand! * secondOperand;
        break;
      case 'Ã·':
        if (secondOperand == 0) {
          _display = 'Ø®Ø·Ø£';
          _expression = '';
          _operator = null;
          _firstOperand = null;
          _isNewOperation = true;
          return;
        }
        result = _firstOperand! / secondOperand;
        break;
    }
    _display = _formatNumber(result);
    _isNewOperation = true;
    _hasDecimal = result != result.floorToDouble();
  }

  String _formatNumber(double number) {
    if (number == number.floorToDouble() && number.abs() < 1e15) {
      return number.toInt().toString();
    }
    String text = number.toStringAsFixed(10);
    text = text.replaceAll(RegExp(r'0+$'), '');
    text = text.replaceAll(RegExp(r'\.$'), '');
    if (text.length > 15) {
      text = number.toStringAsExponential(8);
    }
    return text;
  }

  void _onClearPressed() {
    HapticFeedback.mediumImpact();
    setState(() {
      _display = '0';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _isNewOperation = true;
      _hasDecimal = false;
    });
  }

  void _onDeletePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display.length > 1) {
        if (_display.endsWith('.')) {
          _hasDecimal = false;
        }
        _display = _display.substring(0, _display.length - 1);
      } else {
        _display = '0';
        _isNewOperation = true;
        _hasDecimal = false;
      }
    });
  }

  void _onPercentagePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      double value = double.parse(_display) / 100;
      _display = _formatNumber(value);
      _hasDecimal = value != value.floorToDouble();
    });
  }

  void _onNegatePressed() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_display != '0') {
        if (_display.startsWith('-')) {
          _display = _display.substring(1);
        } else {
          _display = '-$_display';
        }
      }
    });
  }

  Widget _buildButton({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    double flex = 1,
  }) {
    return Expanded(
      flex: flex.round(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 70,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: textColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: text == '0' ? 28 : 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                alignment: Alignment.bottomRight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (_expression.isNotEmpty)
                      Text(
                        _expression,
                        style: TextStyle(
                          fontSize: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _display,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Button grid
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Row 1: AC, C, %, Ã·
                  Row(
                    children: [
                      _buildButton(
                        text: 'AC',
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                        onPressed: _onClearPressed,
                      ),
                      _buildButton(
                        text: 'C',
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                        onPressed: _onDeletePressed,
                      ),
                      _buildButton(
                        text: '%',
                        backgroundColor: colorScheme.secondaryContainer,
                        textColor: colorScheme.onSecondaryContainer,
                        onPressed: _onPercentagePressed,
                      ),
                      _buildButton(
                        text: 'Ã·',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: () => _onOperatorPressed('Ã·'),
                      ),
                    ],
                  ),

                  // Row 2: 7, 8, 9, Ã
                  Row(
                    children: [
                      _buildButton(
                        text: '7',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('7'),
                      ),
                      _buildButton(
                        text: '8',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('8'),
                      ),
                      _buildButton(
                        text: '9',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('9'),
                      ),
                      _buildButton(
                        text: 'Ã',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: () => _onOperatorPressed('Ã'),
                      ),
                    ],
                  ),

                  // Row 3: 4, 5, 6, -
                  Row(
                    children: [
                      _buildButton(
                        text: '4',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('4'),
                      ),
                      _buildButton(
                        text: '5',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('5'),
                      ),
                      _buildButton(
                        text: '6',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('6'),
                      ),
                      _buildButton(
                        text: '-',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: () => _onOperatorPressed('-'),
                      ),
                    ],
                  ),

                  // Row 4: 1, 2, 3, +
                  Row(
                    children: [
                      _buildButton(
                        text: '1',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('1'),
                      ),
                      _buildButton(
                        text: '2',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('2'),
                      ),
                      _buildButton(
                        text: '3',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('3'),
                      ),
                      _buildButton(
                        text: '+',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: () => _onOperatorPressed('+'),
                      ),
                    ],
                  ),

                  // Row 5: 0, ., +/-, =
                  Row(
                    children: [
                      _buildButton(
                        text: '0',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: () => _onDigitPressed('0'),
                        flex: 2,
                      ),
                      _buildButton(
                        text: '.',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: _onDecimalPressed,
                      ),
                      _buildButton(
                        text: '+/-',
                        backgroundColor: colorScheme.surfaceVariant,
                        textColor: colorScheme.onSurfaceVariant,
                        onPressed: _onNegatePressed,
                      ),
                      _buildButton(
                        text: '=',
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                        onPressed: _onEqualsPressed,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```