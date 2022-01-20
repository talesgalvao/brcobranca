# frozen_string_literal: true

require 'spec_helper'

describe Brcobranca::Boleto::CitibankV2 do
  before(:each) do
    @valid_attributes = {
      especie_documento: 'DS',
      moeda: '9',
      data_documento: Date.today,
      dias_vencimento: 1,
      aceite: 'N',
      valor: 25.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Cedente',
      cedente_endereco: "Endereço do cedente - Endereço do cedente - Endereço do cedente -
      Endereço do cedente - Endereço do cedente - Endereço do cedente - Endereço do cedente -
      Endereço do cedente - Endereço do cedente",
      documento_cedente: '20566973000108',
      sacado: 'Teste Sacado',
      sacado_documento: '12979614000146',
      agencia: '0059',
      conta_corrente: '119196019',
      carteira: '101',
      linha_digitavel: '74593112181919601900400000002998488120000001000',
      codigo_barras: '74594881200000010003112119196019000000000299',
      numero_documento: '00000000029',
      instrucao1: 'Instruções para o beneficiário'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('745')
    expect(boleto_novo.especie_documento).to eql('DM')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.today + 1)
    expect(boleto_novo.aceite).to eql('S')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(0.0)
    expect(boleto_novo.valor_documento).to eql(0.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('745')
    expect(boleto_novo.especie_documento).to eql('DS')
    expect(boleto_novo.especie).to eql('R$')
    expect(boleto_novo.moeda).to eql('9')
    expect(boleto_novo.data_documento).to eql(Date.today)
    expect(boleto_novo.dias_vencimento).to eql(1)
    expect(boleto_novo.data_vencimento).to eql(Date.today + 1)
    expect(boleto_novo.aceite).to eql('N')
    expect(boleto_novo.quantidade).to eql(1)
    expect(boleto_novo.valor).to eql(25.0)
    expect(boleto_novo.valor_documento).to eql(25.0)
    expect(boleto_novo.local_pagamento).to eql('QUALQUER BANCO ATÉ O VENCIMENTO')
    expect(boleto_novo.cedente).to eql('Cedente')
    expect(boleto_novo.documento_cedente).to eql('20566973000108')
    expect(boleto_novo.sacado).to eql('Teste Sacado')
    expect(boleto_novo.sacado_documento).to eql('12979614000146')
    expect(boleto_novo.agencia).to eql('0059')
    expect(boleto_novo.numero_documento).to eql('00000000029')
    expect(boleto_novo.carteira).to eql('112')
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_documento] = Date.parse('2011/10/08')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('74594881200000010003112119196019000000000299')
    expect(boleto_novo.linha_digitavel).to eql('74593.11218 19196.019004 00000.002998 4 88120000001000')
    expect(boleto_novo.nosso_numero_boleto).to eq('112/00000000029-9')
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('112/00000000029-9')
  end

  it 'Busca logotipo do banco' do
    boleto_novo = described_class.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end

  it 'Gerar boleto nos formatos válidos com método to_' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.send("to_#{format}".to_sym)
      tmp_file = Tempfile.new(['foobar', ".#{format}"])
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end

  it 'Gerar boleto nos formatos válidos' do
    @valid_attributes[:data_documento] = Date.parse('2009/08/13')
    boleto_novo = described_class.new(@valid_attributes)

    %w[pdf jpg tif png].each do |format|
      file_body = boleto_novo.to(format)
      tmp_file = Tempfile.new(['foobar', ".#{format}"])
      tmp_file.puts file_body
      tmp_file.close
      expect(File.exist?(tmp_file.path)).to be_truthy
      expect(File.stat(tmp_file.path).zero?).to be_falsey
      expect(File.delete(tmp_file.path)).to eql(1)
      expect(File.exist?(tmp_file.path)).to be_falsey
    end
  end
end
