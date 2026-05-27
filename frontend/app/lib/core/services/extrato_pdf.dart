// --- Extrato PDF generator ---

import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/dashboard/models/transaction_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'extrato_pdf_downloader_io.dart'
    if (dart.library.html) 'extrato_pdf_downloader_web.dart';

// brand colours (approximated from AppColors dark values)
const _kBlack      = PdfColor.fromInt(0xFF0A0A0A);
const _kGreen      = PdfColor.fromInt(0xFF2E7D32);
const _kRed        = PdfColor.fromInt(0xFFC62828);
const _kGrey       = PdfColor.fromInt(0xFF757575);
const _kBorder     = PdfColor.fromInt(0xFFE0E0E0);
const _kWhite      = PdfColors.white;

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _dateFmt  = DateFormat('dd/MM/yyyy', 'pt_BR');
final _monthFmt = DateFormat('MMMM yyyy', 'pt_BR');

/// Generates a styled PDF for [transactions] and opens the share/print sheet.
/// [month] and [year] define the period label shown in the header.
Future<void> exportExtratoPdf({
  required List<TransactionModel> transactions,
  required String userName,
  required int month,
  required int year,
}) async {
  final doc  = pw.Document();
  final font = await PdfGoogleFonts.interRegular();
  final bold = await PdfGoogleFonts.interBold();

  final monthLabel = _monthFmt.format(DateTime(year, month));
  final txs        = transactions;

  // summary totals
  double totalEntradas = 0;
  double totalSaidas   = 0;
  for (final t in txs) {
    if (t.type == 'deposit' || t.type == 'sell') {
      totalEntradas += t.amount;
    } else {
      totalSaidas += t.amount;
    }
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
      footer: (ctx) => _footer(font, ctx.pageNumber, ctx.pagesCount),
      build: (ctx) => [
        _header(bold, font, userName, monthLabel),
        pw.SizedBox(height: 24),
        _summaryRow(bold, font, totalEntradas, totalSaidas),
        pw.SizedBox(height: 24),
        _tableHeader(bold),
        if (txs.isEmpty)
          _emptyState(font)
        else
          ...txs.map((t) => _tableRow(font, bold, t)),
      ],
    ),
  );

  final bytes    = await doc.save();
  final filename = 'extrato_${year}_${month.toString().padLeft(2, '0')}.pdf';

  await downloadOrShare(bytes, filename);
}

// ── Header ────────────────────────────────────────────────────────────────────

pw.Widget _header(pw.Font bold, pw.Font font, String userName, String month) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: _kBlack,
      borderRadius: pw.BorderRadius.circular(12),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 22),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Mescla Invest',
              style: pw.TextStyle(font: bold, fontSize: 22, color: _kWhite),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Extrato de transações',
              style: pw.TextStyle(font: font, fontSize: 12, color: PdfColor.fromInt(0xFFBBBBBB)),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              userName,
              style: pw.TextStyle(font: bold, fontSize: 13, color: _kWhite),
            ),
            pw.SizedBox(height: 4),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF2A2A2A),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                month,
                style: pw.TextStyle(font: font, fontSize: 11, color: PdfColor.fromInt(0xFFBBBBBB)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

// ── Summary cards ─────────────────────────────────────────────────────────────

pw.Widget _summaryRow(pw.Font bold, pw.Font font, double entradas, double saidas) {
  return pw.Row(
    children: [
      pw.Expanded(child: _summaryCard(bold, font, 'Entradas', entradas, _kGreen)),
      pw.SizedBox(width: 12),
      pw.Expanded(child: _summaryCard(bold, font, 'Saídas',   saidas,   _kRed)),
      pw.SizedBox(width: 12),
      pw.Expanded(child: _summaryCard(bold, font, 'Saldo do período', entradas - saidas,
          entradas >= saidas ? _kGreen : _kRed)),
    ],
  );
}

pw.Widget _summaryCard(pw.Font bold, pw.Font font, String label, double value, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _kBorder),
      borderRadius: pw.BorderRadius.circular(10),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10, color: _kGrey)),
        pw.SizedBox(height: 6),
        pw.Text(
          _currency.format(value),
          style: pw.TextStyle(font: bold, fontSize: 13, color: color),
        ),
      ],
    ),
  );
}

// ── Table ─────────────────────────────────────────────────────────────────────

pw.Widget _tableHeader(pw.Font bold) {
  return pw.Container(
    color: _kBlack,
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: pw.Row(
      children: [
        pw.Expanded(flex: 3, child: _th(bold, 'Descrição')),
        pw.Expanded(flex: 1, child: _th(bold, 'Data',     align: pw.TextAlign.center)),
        pw.Expanded(flex: 1, child: _th(bold, 'Tipo',     align: pw.TextAlign.center)),
        pw.Expanded(flex: 2, child: _th(bold, 'Valor',    align: pw.TextAlign.right)),
      ],
    ),
  );
}

pw.Widget _th(pw.Font bold, String text, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(font: bold, fontSize: 10, color: _kWhite),
  );
}

pw.Widget _tableRow(pw.Font font, pw.Font bold, TransactionModel t) {
  final isPositive = t.type == 'deposit' || t.type == 'sell';
  final color      = isPositive ? _kGreen : _kRed;
  final prefix     = isPositive ? '+' : '-';
  final typeLabel  = switch (t.type) {
    'deposit' => 'Depósito',
    'buy'     => 'Compra',
    'sell'    => 'Venda',
    _         => 'Outro',
  };

  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _kBorder, width: 0.5)),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            t.description,
            style: pw.TextStyle(font: font, fontSize: 10, color: _kBlack),
            maxLines: 2,
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            _dateFmt.format(t.createdAt),
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(font: font, fontSize: 10, color: _kGrey),
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: pw.BoxDecoration(
                color: isPositive
                    ? PdfColor.fromInt(0xFFE8F5E9)
                    : PdfColor.fromInt(0xFFFFEBEE),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Text(
                typeLabel,
                style: pw.TextStyle(font: bold, fontSize: 9, color: color),
              ),
            ),
          ),
        ),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            '$prefix ${_currency.format(t.amount)}',
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(font: bold, fontSize: 10, color: color),
          ),
        ),
      ],
    ),
  );
}

pw.Widget _emptyState(pw.Font font) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 32),
    child: pw.Center(
      child: pw.Text(
        'Nenhuma transação neste mês.',
        style: pw.TextStyle(font: font, fontSize: 12, color: _kGrey),
      ),
    ),
  );
}

// ── Footer ────────────────────────────────────────────────────────────────────

pw.Widget _footer(pw.Font font, int pageNumber, int pagesCount) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: _kBorder)),
    ),
    padding: const pw.EdgeInsets.only(top: 10),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Mescla Invest — documento gerado automaticamente',
          style: pw.TextStyle(font: font, fontSize: 9, color: _kGrey),
        ),
        pw.Text(
          'Gerado em ${_dateFmt.format(DateTime.now())}   •   $pageNumber / $pagesCount',
          style: pw.TextStyle(font: font, fontSize: 9, color: _kGrey),
        ),
      ],
    ),
  );
}
