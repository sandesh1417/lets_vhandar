import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:lets_vhandar/features/order/domain/models/order_model.dart';

// ── Brand constants ───────────────────────────────────────────────────────────
const _green = PdfColor.fromInt(0xFF3B9171);
const _amber = PdfColor.fromInt(0xFFF5B237);
const _darkText = PdfColor.fromInt(0xFF1A1A1A);
const _mutedText = PdfColor.fromInt(0xFF6B7280);
const _divider = PdfColor.fromInt(0xFFE5E7EB);
const _lightBg = PdfColor.fromInt(0xFFF9FAFB);
const _greenBg = PdfColor.fromInt(0xFFE8F5EF);

const _companyName = 'Vhandar Merchandise Pvt. Ltd.';
const _email = 'info@vhandar.com';
const _website = 'www.vhandar.com';
const _phone = '+(977)-9851357358';
const _address = 'Shankamul Kathmandu';
const _vatNo = '621233397';

// ── Date helpers ──────────────────────────────────────────────────────────────
String _monthName(int m) => const [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m - 1];

String _fmtDate(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '${_monthName(d.month)} ${d.day.toString().padLeft(2, '0')} ${d.year} $h:$min';
}

String _fmtNum(num? v) => (v ?? 0).toStringAsFixed(2);

// ── Main builder ─────────────────────────────────────────────────────────────
Future<Uint8List> buildReceiptPdf(OrderData order) async {
  final pdf = pw.Document();

  // Load SVG logo
  String? logoSvg;
  try {
    logoSvg = await rootBundle.loadString('assets/images/vhandar_logo.svg');
  } catch (_) {}

  final products = order.products ?? [];
  final date = order.createdAt != null ? _fmtDate(order.createdAt!) : '—';

  // Address
  final loc = order.location;
  final customerName = loc?.name ?? '—';
  final customerAddr = loc?.description ?? '—';
  final customerPhone = loc?.phoneNumber ?? '—';

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(36, 32, 36, 48),
      footer: (ctx) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.only(top: 6),
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: _divider, width: 0.5)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Vhandar Merchandise Pvt. Ltd.  •  VAT: $_vatNo',
              style: const pw.TextStyle(fontSize: 7, color: _mutedText),
            ),
            pw.Text(
              'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: _mutedText),
            ),
          ],
        ),
      ),
      build: (ctx) => [
        // ── Header ──────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo + company name
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logoSvg != null)
                  pw.SvgImage(svg: logoSvg, width: 80, height: 74)
                else
                  pw.Text('Vhandar',
                      style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: _green)),
                pw.SizedBox(height: 4),
                pw.Text(_companyName,
                    style: const pw.TextStyle(
                        fontSize: 9, color: _mutedText)),
              ],
            ),
            pw.Spacer(),
            // Company info right side
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                _companyInfoRow('Email:', _email),
                _companyInfoRow('Website:', _website),
                _companyInfoRow('Phone No:', _phone),
                _companyInfoRow('Address:', _address),
                _companyInfoRow('VAT NO:', _vatNo),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 16),

        // ── Info bar ─────────────────────────────────────────────────
        pw.Table(
          border: pw.TableBorder.all(color: _divider, width: 0.5),
          columnWidths: {
            0: const pw.FlexColumnWidth(1.3),
            1: const pw.FlexColumnWidth(1.5),
            2: const pw.FlexColumnWidth(1.2),
            3: const pw.FlexColumnWidth(1.2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _lightBg),
              children: [
                _infoCell('#${order.orderId ?? '—'}', 'Invoice No', bold: true, color: _green),
                _infoCell(date, 'Invoice Date'),
                _infoCell(
                    _capitalize(order.paymentStatus ?? 'Pending'),
                    'Payment Status',
                    color: _amber),
                _infoCell(
                    'Rs.${_fmtNum(order.totalPayableAmount)}',
                    'Total Amount',
                    bold: true,
                    color: _green),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 14),

        // ── Bill To / Shipping To ────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILL TO',
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                  pw.SizedBox(height: 3),
                  pw.Text(customerName,
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _darkText)),
                  pw.SizedBox(height: 2),
                  pw.Text(customerAddr,
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                  pw.SizedBox(height: 2),
                  pw.Text(customerPhone,
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                ],
              ),
            ),
            pw.SizedBox(width: 24),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('SHIPPING TO',
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                  pw.SizedBox(height: 3),
                  pw.Text(customerName,
                      style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: _darkText)),
                  pw.SizedBox(height: 2),
                  pw.Text(customerAddr,
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                  pw.SizedBox(height: 2),
                  pw.Text(customerPhone,
                      style: const pw.TextStyle(
                          fontSize: 9, color: _mutedText)),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 16),

        // ── Items table ──────────────────────────────────────────────
        pw.Table(
          border: pw.TableBorder.all(color: _divider, width: 0.5),
          columnWidths: {
            0: const pw.FixedColumnWidth(32),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FixedColumnWidth(60),
            3: const pw.FixedColumnWidth(70),
            4: const pw.FixedColumnWidth(70),
          },
          children: [
            // Header
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: _green),
              children: [
                _th('S.NO'),
                _th('ITEMS NAME'),
                _th('QUANTITY'),
                _th('RATE'),
                _th('AMOUNT'),
              ],
            ),
            // Product rows
            ...List.generate(products.length, (i) {
              final p = products[i];
              final qty = p.count ?? 1;
              final rate = p.pricePerUnit ?? p.netPrice ?? 0;
              final amount = p.totalPrice ?? p.netPrice ?? 0;
              final unitLabel =
                  '${p.unitValue?.toInt() ?? ''} ${p.unit ?? ''}'.trim();
              final itemName = [
                p.name ?? '—',
                if (unitLabel.isNotEmpty) unitLabel,
              ].join(' - ');
              final bg = i.isEven ? PdfColors.white : _lightBg;
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: bg),
                children: [
                  _td('${i + 1}', center: true),
                  _td(itemName),
                  _td('$qty', center: true),
                  _td(_fmtNum(rate), right: true),
                  _td(_fmtNum(amount), right: true, bold: true),
                ],
              );
            }),
          ],
        ),

        pw.SizedBox(height: 16),

        // ── Bill summary (right-aligned block) ───────────────────────
        pw.Row(
          children: [
            pw.Spacer(),
            pw.SizedBox(
              width: 260,
              child: pw.Column(
                children: [
                  _summaryRow('Sub Total',
                      'Rs. ${_fmtNum(order.totalAmount)}',
                      bold: true),
                  _summaryDivider(),
                  _summaryRow('Estimated Tax (VAT)',
                      'Rs.${_fmtNum(order.totalVatAmount)}'),
                  _summaryDivider(),
                  _summaryRow('Item Discounts',
                      'Rs. ${_fmtNum(order.totalDiscount)}',
                      valueColor: (order.totalDiscount ?? 0) > 0
                          ? const PdfColor.fromInt(0xFF2E7D32)
                          : null),
                  _summaryDivider(),
                  _summaryRow('Delivery Charge',
                      'Rs. ${_fmtNum(order.deliveryCharge)}'),
                  _summaryDivider(),
                  _summaryRow('Handling Charge',
                      'Rs. ${_fmtNum(order.handlingCharge)}'),
                  pw.SizedBox(height: 4),
                  // Total row
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: _greenBg,
                      border: pw.Border.all(color: _green, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Total Amount',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                                color: _green)),
                        pw.Text(
                            'Rs.${_fmtNum(order.totalPayableAmount)}',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 12,
                                color: _green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        pw.SizedBox(height: 20),

        // ── Payment details ──────────────────────────────────────────
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: _lightBg,
            border: pw.Border.all(color: _divider, width: 0.5),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PAYMENT DETAILS',
                  style: const pw.TextStyle(
                      fontSize: 9, color: _mutedText)),
              pw.SizedBox(height: 4),
              pw.RichText(
                text: pw.TextSpan(children: [
                  const pw.TextSpan(
                      text: 'Payment Method: ',
                      style: pw.TextStyle(
                          fontSize: 10, color: _darkText)),
                  pw.TextSpan(
                      text: order.paymentMethod ?? '—',
                      style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: _darkText)),
                ]),
              ),
              if ((order.paymentStatus ?? '').isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.RichText(
                  text: pw.TextSpan(children: [
                    const pw.TextSpan(
                        text: 'Payment Status: ',
                        style: pw.TextStyle(
                            fontSize: 10, color: _darkText)),
                    pw.TextSpan(
                        text: _capitalize(order.paymentStatus!),
                        style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: _green)),
                  ]),
                ),
              ],
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // ── Footer ──────────────────────────────────────────────────
        pw.Divider(color: _divider),
        pw.SizedBox(height: 6),
        pw.Center(
          child: pw.Text(
            'Thank you for shopping with Vhandar!',
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _green),
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Center(
          child: pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            style: const pw.TextStyle(fontSize: 8, color: _mutedText),
          ),
        ),
      ],
    ),
  );

  return pdf.save();
}

// ── Widget helpers ────────────────────────────────────────────────────────────

pw.Widget _companyInfoRow(String label, String value) =>
    pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.RichText(
        text: pw.TextSpan(children: [
          pw.TextSpan(
              text: '$label ',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: _darkText)),
          pw.TextSpan(
              text: value,
              style: const pw.TextStyle(fontSize: 9, color: _mutedText)),
        ]),
      ),
    );

pw.Widget _infoCell(String value, String subtitle,
    {bool bold = false, PdfColor? color}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight:
                      bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                  color: color ?? _darkText)),
          pw.SizedBox(height: 2),
          pw.Text(subtitle,
              style: const pw.TextStyle(fontSize: 8, color: _mutedText)),
        ],
      ),
    );

pw.Widget _th(String text) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(text,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white)),
    );

pw.Widget _td(String text,
    {bool center = false, bool right = false, bool bold = false}) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Text(text,
          textAlign: center
              ? pw.TextAlign.center
              : right
                  ? pw.TextAlign.right
                  : pw.TextAlign.left,
          style: pw.TextStyle(
              fontSize: 9,
              fontWeight:
                  bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: _darkText)),
    );

pw.Widget _summaryRow(String label, String value,
    {bool bold = false, PdfColor? valueColor}) =>
    pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: bold ? _darkText : _mutedText)),
        pw.Text(value,
            style: pw.TextStyle(
                fontSize: 10,
                fontWeight:
                    bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                color: valueColor ?? (bold ? _darkText : _mutedText))),
      ],
    );

pw.Widget _summaryDivider() => pw.Container(
    height: 0.5,
    margin: const pw.EdgeInsets.symmetric(vertical: 5),
    color: _divider);

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
