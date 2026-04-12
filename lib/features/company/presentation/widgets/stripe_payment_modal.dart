import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentModal extends StatefulWidget {
  final String clientSecret;
  final String planNombre;
  final int amountCentavos;

  const StripePaymentModal({
    super.key,
    required this.clientSecret,
    required this.planNombre,
    required this.amountCentavos,
  });

  @override
  State<StripePaymentModal> createState() => _StripePaymentModalState();
}

class _StripePaymentModalState extends State<StripePaymentModal> {
  bool _isProcessing = false;
  bool _isCardValid = false;

  Future<void> _processPayment() async {
    if (!_isCardValid) return;

    setState(() => _isProcessing = true);

    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: widget.clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      if (paymentIntent.status == PaymentIntentsStatus.Succeeded) {
        if (!mounted) return;
        Navigator.of(context).pop(true); // Success
      } else {
        if (!mounted) return;
        Navigator.of(context).pop(false); // Failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pago no completado: ${paymentIntent.status}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on StripeException catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Stripe: ${e.error.localizedMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar pago: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final amountFormatted = (widget.amountCentavos / 100).toStringAsFixed(2);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Información de Pago',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Plan: ${widget.planNombre}',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            'Monto a pagar: \$$amountFormatted USD',
            style: const TextStyle(
              color: Color(0xFF8B5CF6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          
          // Campo de tarjeta de Stripe
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CardField(
              onCardChanged: (card) {
                setState(() {
                  _isCardValid = card?.complete ?? false;
                });
              },
            ),
          ),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_isCardValid && !_isProcessing) ? _processPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                disabledBackgroundColor: Colors.grey.shade800,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Pagar ahora',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
