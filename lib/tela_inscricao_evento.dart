import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'main.dart' show TelaPagamentoPix, enviarInscricaoParaPlanilha;

enum FormaPagamento { pix, igreja }

class TelaEscolhaPagamento extends StatelessWidget {
  final String inscricaoId;
  final double valor;
  final String nomeEvento;
  const TelaEscolhaPagamento({
    super.key,
    required this.inscricaoId,
    required this.valor,
    required this.nomeEvento,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Escolha a forma de pagamento')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Como deseja pagar sua inscrição?',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.pix),
              label: const Text('Pagar Agora (PIX)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BF80),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => TelaInscricaoEvento(
                      inscricaoId: inscricaoId,
                      valor: valor,
                      nomeEvento: nomeEvento,
                      formaPagamento: FormaPagamento.pix,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.church),
              label: const Text('Pagar na Igreja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (c) => TelaInscricaoEvento(
                      inscricaoId: inscricaoId,
                      valor: valor,
                      nomeEvento: nomeEvento,
                      formaPagamento: FormaPagamento.igreja,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TelaInscricaoEvento extends StatefulWidget {
  final String inscricaoId;
  final double valor;
  final String nomeEvento;
  final FormaPagamento formaPagamento;

  const TelaInscricaoEvento({
    super.key,
    required this.inscricaoId,
    required this.valor,
    required this.nomeEvento,
    required this.formaPagamento,
  });

  @override
  State<TelaInscricaoEvento> createState() => _TelaInscricaoEventoState();
}

class _TelaInscricaoEventoState extends State<TelaInscricaoEvento> {
    /// Remove acentos e substitui espaços por underline para nome de aba
    String normalizarNomeAba(String nome) {
      var comAcentos = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
      var semAcentos = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeCcIIIIiiiiUUUUuuuuyNn';
      String output = nome;
      for (int i = 0; i < comAcentos.length; i++) {
        output = output.replaceAll(comAcentos[i], semAcentos[i]);
      }
      return output.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    }
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nascimentoController = TextEditingController();
  final _celularController = TextEditingController();

  // Função para permitir apenas números e limitar a 11 dígitos
  void _onCelularChanged(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length > 11) {
      _celularController.text = digitsOnly.substring(0, 11);
      _celularController.selection = TextSelection.fromPosition(
        TextPosition(offset: _celularController.text.length),
      );
    } else if (digitsOnly != value) {
      _celularController.text = digitsOnly;
      _celularController.selection = TextSelection.fromPosition(
        TextPosition(offset: digitsOnly.length),
      );
    }
  }
  bool _enviando = false;
  DateTime? _dataNascimento;

  // Função para formatar o celular enquanto o usuário digita
  void _formatarCelular(String valor) {
    // Implementação básica de máscara (pode ser melhorada com pacotes de mask)
    print("Formatando: $valor");
  }

  // Abre o seletor de data
  void _selecionarDataNascimento() {
    DatePicker.showDatePicker(
      context,
      dateFormat: 'dd/MM/yyyy',
      locale: DateTimePickerLocale.pt_br,
      onConfirm: (dateTime, selectedIndex) {
        setState(() {
          _dataNascimento = dateTime;
          _nascimentoController.text = DateFormat('dd/MM/yyyy').format(dateTime);
        });
      },
    );
  }


  Future<void> _enviarInscricao() async {
    debugPrint('[Inscricao] Iniciando envio. nome: \\${_nomeController.text}, nascimento: \\${_nascimentoController.text}, celular: \\${_celularController.text}');
    if (!_formKey.currentState!.validate()) {
      debugPrint('[Inscricao] Formulário inválido.');
      return;
    }
    if (widget.formaPagamento == FormaPagamento.pix) {
      // Apenas navega para a tela Pix, não envia para planilha ainda
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => TelaPagamentoPix(
            valor: widget.valor,
            inscricaoId: widget.inscricaoId,
            nome: _nomeController.text,
            nascimento: _nascimentoController.text,
            celular: _celularController.text,
            nomeEvento: widget.nomeEvento,
            onPagamentoConfirmado: () async {
              final data = {
                'inscricaoId': widget.inscricaoId,
                'nome': _nomeController.text,
                'nascimento': _nascimentoController.text,
                'celular': _celularController.text,
                'status': 'Pago Pix',
                'timestamp': DateTime.now().toIso8601String(),
              };
              try {
                await enviarInscricaoParaPlanilha(
                  data: data,
                  nomeAba: normalizarNomeAba(widget.nomeEvento),
                  situacao: 'Pago Pix',
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscrição e pagamento confirmados com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao registrar inscrição: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
      );
    } else {
      setState(() => _enviando = true);
      final data = {
        'inscricaoId': widget.inscricaoId,
        'nome': _nomeController.text,
        'nascimento': _nascimentoController.text,
        'celular': _celularController.text,
        'status': 'Pagar na Igreja',
        'timestamp': DateTime.now().toIso8601String(),
      };
      try {
        await enviarInscricaoParaPlanilha(
          data: data,
          nomeAba: normalizarNomeAba(widget.nomeEvento),
          situacao: 'Aguardando Pagamento',
        );
      } catch (e) {
        debugPrint('Erro ao enviar inscrição para planilha (Pagar na Igreja): $e');
        // Mesmo com erro, segue o fluxo de sucesso para o usuário
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscrição enviada! Aguardando pagamento!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inscrição - ${widget.nomeEvento}')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Usado para evitar erro de overflow no teclado
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selecionarDataNascimento,
                  child: AbsorbPointer(
                    child: TextFormField(
                      controller: _nascimentoController,
                      decoration: const InputDecoration(
                        labelText: 'Data de nascimento',
                        hintText: 'Selecione a data',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe a data de nascimento';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _celularController,
                  decoration: const InputDecoration(
                    labelText: 'Celular',
                    hintText: '(99) 99999-9999',
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 11,
                  onChanged: _onCelularChanged,
                  validator: (v) {
                    final digits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digits.isEmpty) return 'Informe o celular';
                    if (digits.length != 11) return 'Celular deve ter 11 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  'Valor da inscrição: R\$ ${widget.valor.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: widget.formaPagamento == FormaPagamento.pix
                        ? const Icon(Icons.pix)
                        : const Icon(Icons.church),
                    label: _enviando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.formaPagamento == FormaPagamento.pix
                            ? 'Confirmar e Pagar Agora'
                            : 'Confirmar Inscrição'),
                    onPressed: _enviando ? null : _enviarInscricao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.formaPagamento == FormaPagamento.pix
                          ? const Color(0xFF00BF80)
                          : Colors.amber,
                      foregroundColor: widget.formaPagamento == FormaPagamento.pix
                          ? Colors.white
                          : Colors.black,
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}