const express = require('express');
require('dotenv').config();
const mercadopago = require('mercadopago');
const cors = require('cors');
const app = express();
app.use(cors());
app.use(express.json());

// Configure sua chave de acesso do Mercado Pago
// Use variável de ambiente para a chave de acesso do Mercado Pago
mercadopago.configure({
  access_token: process.env.MERCADOPAGO_ACCESS_TOKEN || 'SUA_CHAVE_AQUI'
});

app.post('/criar-pix', async (req, res) => {
  const { valor, inscricaoId } = req.body;
  console.log('Recebido body:', req.body);
  console.log('Valor recebido:', valor, '| Inscrição:', inscricaoId);
  try {
    const payment_data = {
      transaction_amount: Number(valor),
      description: `Pagamento inscrição ${inscricaoId}`,
      payment_method_id: 'pix',
      payer: {
        email: 'comprador@email.com', // Substitua pelo email real do pagador
      }
    };
    const payment = await mercadopago.payment.create(payment_data);
    const pixInfo = payment.body.point_of_interaction.transaction_data;
    res.json({
      qrCodeImageUrl: pixInfo.qr_code_base64 ? `data:image/png;base64,${pixInfo.qr_code_base64}` : null,
      copiaECola: pixInfo.qr_code,
    });
  } catch (err) {
    console.error('Erro ao criar pagamento PIX:', err);
    res.status(400).json({ error: err.message });
  }
});

app.listen(3000, () => console.log('Backend rodando na porta 3000'));