import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
const __dirname = path.dirname(fileURLToPath(import.meta.url));

// توليد QR Code بتنسيق نصي
export function generateSimpleQR(data) {
  return Buffer.from(JSON.stringify(data)).toString('base64');
}

// توليد XML للفاتورة الإلكترونية
export function generateInvoiceXML(invoice, lines, company) {
  const uuid = generateUUID();
  const timestamp = new Date().toISOString();
  
  const linesXML = lines.map((line, idx) => `
    <cac:InvoiceLine>
      <cbc:ID>${idx + 1}</cbc:ID>
      <cbc:InvoicedQuantity unitCode="PCE">${line.quantity}</cbc:InvoicedQuantity>
      <cac:Item>
        <cbc:Name>${escapeXML(line.name)}</cbc:Name>
      </cac:Item>
      <cac:Price>
        <cbc:PriceAmount currencyID="SAR">${line.unit_price}</cbc:PriceAmount>
      </cac:Price>
      <cac:LineExtensionAmount currencyID="SAR">${line.line_total}</cac:LineExtensionAmount>
    </cac:InvoiceLine>
  `).join('');

  const xml = `<?xml version="1.0" encoding="UTF-8"?>
<Invoice xmlns="urn:oasis:names:specification:ubl:schema:xsd:Invoice-2">
  <cbc:ID>${invoice.invoice_number}</cbc:ID>
  <cbc:IssueDate>${invoice.invoice_date}</cbc:IssueDate>
  <cbc:IssueTime>${timestamp.split('T')[1]}</cbc:IssueTime>
  <cbc:InvoiceTypeCode>${invoice.invoice_type === 'sales' ? '388' : '381'}</cbc:InvoiceTypeCode>
  <cbc:DocumentCurrencyCode>SAR</cbc:DocumentCurrencyCode>
  <cac:AccountingSupplierParty>
    <cac:Party>
      <cbc:Name>${escapeXML(company.company_name)}</cbc:Name>
      <cbc:RegistrationName>${escapeXML(company.company_name)}</cbc:RegistrationName>
      <cac:PartyTaxScheme>
        <cbc:CompanyID>${company.tax_number}</cbc:CompanyID>
      </cac:PartyTaxScheme>
      <cac:PostalAddress>
        <cbc:StreetName>${escapeXML(company.address)}</cbc:StreetName>
      </cac:PostalAddress>
    </cac:Party>
  </cac:AccountingSupplierParty>
  <cac:LegalMonetaryTotal>
    <cbc:LineExtensionAmount currencyID="SAR">${invoice.subtotal}</cbc:LineExtensionAmount>
    <cbc:TaxExclusiveAmount currencyID="SAR">${invoice.subtotal}</cbc:TaxExclusiveAmount>
    <cbc:TaxInclusiveAmount currencyID="SAR">${invoice.total}</cbc:TaxInclusiveAmount>
    <cbc:PayableAmount currencyID="SAR">${invoice.total}</cbc:PayableAmount>
  </cac:LegalMonetaryTotal>
  ${linesXML}
</Invoice>`;
  
  return { xml, uuid };
}

function escapeXML(str) {
  if (!str) return '';
  return str.replace(/[<>&'"]/g, char => {
    const map = {
      '<': '&lt;',
      '>': '&gt;',
      '&': '&amp;',
      "'": '&apos;',
      '"': '&quot;'
    };
    return map[char];
  });
}

function generateUUID() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

// محاكاة إرسال إلى ZATCA
export async function submitToZATCA(xmlData, certificate) {
  // هذا نموذج - يحتاج إلى تطبيق حقيقي مع شهادة ZATCA
  console.log('Submitting to ZATCA...', xmlData.substring(0, 100));
  
  return {
    status: 'accepted',
    uuid: 'zatca-uuid-xxx',
    timestamp: new Date().toISOString()
  };
}

// حساب ضريبة القيمة المضافة
export function calculateVAT(amount, vatRate = 0.15) {
  return parseFloat((amount * vatRate).toFixed(2));
}

// التحقق من توازن القيد المحاسبي
export function verifyEntryBalance(lines) {
  const totalDebit = lines.reduce((sum, line) => sum + (parseFloat(line.debit) || 0), 0);
  const totalCredit = lines.reduce((sum, line) => sum + (parseFloat(line.credit) || 0), 0);
  
  return Math.abs(totalDebit - totalCredit) < 0.01;
}

export default {
  generateSimpleQR,
  generateInvoiceXML,
  submitToZATCA,
  calculateVAT,
  verifyEntryBalance
};
