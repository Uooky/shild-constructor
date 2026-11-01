import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExportService {
  Future<File> exportProject({
    required String projectName,
    required String objectName,
    required String author,
    required String dateText,
    required String drawingSummary,
    required String equipmentSummary,
    required String estimateSummary,
    required String calculationsSummary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Shield Designer', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Text('Проект: $projectName'),
          pw.Text('Объект: $objectName'),
          pw.Text('Дата: $dateText'),
          pw.Text('Автор: $author'),
          pw.SizedBox(height: 20),
          pw.Text('Монтажный чертёж', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(drawingSummary),
          pw.SizedBox(height: 16),
          pw.Text('Спецификация оборудования', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(equipmentSummary),
          pw.SizedBox(height: 16),
          pw.Text('Смета', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(estimateSummary),
          pw.SizedBox(height: 16),
          pw.Text('Расчёты', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.Text(calculationsSummary),
        ],
      ),
    );

    final file = File('/tmp/${projectName.replaceAll(' ', '_')}_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
