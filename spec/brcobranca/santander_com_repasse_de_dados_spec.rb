# frozen_string_literal: true

require 'spec_helper'

describe Brcobranca::Boleto::SantanderComRepasseDeRegras do
  before(:each) do
    @valid_attributes = {
      especie_documento: 'DS',
      moeda: '9',
      data_documento: Date.today,
      dias_vencimento: 1,
      aceite: 'N',
      quantidade: 1,
      valor: 25.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      cedente_endereco: "Endereço do cedente - Endereço do cedente - Endereço do cedente -
      Endereço do cedente - Endereço do cedente - Endereço do cedente - Endereço do cedente -
      Endereço do cedente - Endereço do cedente",
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '0059',
      carteira: '101',
      codigo_cedente: '002769131',
      linha_digitavel: '03399276911310000000200000101014381000000001000',
      codigo_barras: '03393810000000010009276913100000000000010101',
      nosso_numero_boleto: '0000000000001',
      seu_numero: '0000000000005',
      numero_documento: '90000267',
      instrucao1: 'Instruções para o beneficiário'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('033')
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
    expect(boleto_novo.banco).to eql('033')
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
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.agencia).to eql('0059')
    expect(boleto_novo.convenio).to eql('002769131')
    expect(boleto_novo.numero_documento).to eql('90000267')
    expect(boleto_novo.carteira).to eql('101')
  end

  it 'Gerar boleto' do
    @valid_attributes[:data_documento] = Date.parse('2011/10/08')
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.codigo_barras).to eql('03393810000000010009276913100000000000010101')
    expect(boleto_novo.linha_digitavel).to eql('03399.27691 13100.000002 00000.101014 3 81000000001000')
    expect(boleto_novo.seu_numero).to eq('0000000000005')
    expect(boleto_novo.nosso_numero_boleto).to eq('000000000000-1')
  end

  it 'Montar nosso_numero_boleto' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.nosso_numero_boleto).to eql('000000000000-1')
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
