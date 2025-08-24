import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class InvoiceRepository {
  final ApiService _apiService = ApiService.instance;

  // Get user invoices
  Future<Map<String, dynamic>> getUserInvoices() async {
    try {
      final response = await _apiService.get(AppConstants.invoices);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['invoices'] != null) {
          final invoices = (responseData['invoices'] as List)
              .map((invoiceJson) => Invoice.fromJson(invoiceJson))
              .toList();

          return {
            'success': true,
            'invoices': invoices,
            'message': 'تم جلب الفواتير بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب الفواتير',
      };
    } catch (e) {
      print('Get user invoices error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Mark invoice as paid
  Future<Map<String, dynamic>> markInvoiceAsPaid(
      String invoiceId, String paymentMethod) async {
    try {
      final path = AppConstants.invoiceMarkPaid.replaceAll('{id}', invoiceId);
      final response = await _apiService.put(
        path,
        data: {
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم تحديث حالة الدفع بنجاح',
        };
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في تحديث حالة الدفع',
        };
      }
    } catch (e) {
      print('Mark invoice as paid error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Update payment status
  Future<Map<String, dynamic>> updatePaymentStatus(
    String invoiceId,
    String paymentStatus,
    String paymentMethod,
  ) async {
    try {
      final path =
          AppConstants.invoicePaymentStatus.replaceAll('{id}', invoiceId);
      final response = await _apiService.put(
        path,
        data: {
          'paymentStatus': paymentStatus,
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم تحديث حالة الدفع بنجاح',
        };
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في تحديث حالة الدفع',
        };
      }
    } catch (e) {
      print('Update payment status error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Mark invoice as failed
  Future<Map<String, dynamic>> markInvoiceAsFailed(String invoiceId) async {
    try {
      final path = AppConstants.invoiceMarkFailed.replaceAll('{id}', invoiceId);
      final response = await _apiService.put(path, data: {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم تحديث حالة الفاتورة بنجاح',
        };
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في تحديث حالة الفاتورة',
        };
      }
    } catch (e) {
      print('Mark invoice as failed error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Refund invoice
  Future<Map<String, dynamic>> refundInvoice(String invoiceId) async {
    try {
      final path = AppConstants.invoiceRefund.replaceAll('{id}', invoiceId);
      final response = await _apiService.put(path, data: {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم إرجاع المبلغ بنجاح',
        };
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إرجاع المبلغ',
        };
      }
    } catch (e) {
      print('Refund invoice error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }

  // Get invoice by ID
  Future<Map<String, dynamic>> getInvoiceById(String invoiceId) async {
    try {
      final response =
          await _apiService.get('${AppConstants.invoices}/$invoiceId');

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['invoice'] != null) {
          final invoice = Invoice.fromJson(responseData['invoice']);
          return {
            'success': true,
            'invoice': invoice,
            'message': 'تم جلب الفاتورة بنجاح',
          };
        }
      }

      return {
        'success': false,
        'message': 'فشل في جلب الفاتورة',
      };
    } catch (e) {
      print('Get invoice by ID error: $e');
      return {
        'success': false,
        'message': 'خطأ في الاتصال بالخادم',
      };
    }
  }
}
