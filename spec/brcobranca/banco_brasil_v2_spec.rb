# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Brcobranca::Boleto::BancoBrasilV2 do #:nodoc:[all]

  before(:each) do
    @valid_attributes = {
      especie_documento: 'DM',
      moeda: '9',
      data_documento: Date.today,
      dias_vencimento: 1,
      aceite: 'S',
      quantidade: 1,
      valor: 0.0,
      local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO',
      cedente: 'Kivanio Barbosa',
      documento_cedente: '12345678912',
      sacado: 'Claudio Pozzebom',
      sacado_documento: '12345678900',
      agencia: '4042',
      conta_corrente: '61900',
      convenio: 12_387_989,
      numero_documento: '777700168',
      linha_digitavel: '03399276911310000000200000101014381000000001000',
      codigo_barras: '03393810000000010009276913100000000000010101'
    }
  end

  it 'Criar nova instancia com atributos padrões' do
    boleto_novo = described_class.new
    expect(boleto_novo.banco).to eql('001')
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
    expect(boleto_novo.carteira).to eql('17')
    expect(boleto_novo.codigo_servico).to be_falsey
    expect(boleto_novo.linha_digitavel).to be_blank
    expect(boleto_novo.codigo_barras).to be_blank
    expect(boleto_novo.nosso_numero_boleto).to eq '0000000000000'
  end

  it 'Criar nova instancia com atributos válidos' do
    boleto_novo = described_class.new(@valid_attributes)
    expect(boleto_novo.banco).to eql('001')
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
    expect(boleto_novo.cedente).to eql('Kivanio Barbosa')
    expect(boleto_novo.documento_cedente).to eql('12345678912')
    expect(boleto_novo.sacado).to eql('Claudio Pozzebom')
    expect(boleto_novo.sacado_documento).to eql('12345678900')
    expect(boleto_novo.conta_corrente).to eql('00061900')
    expect(boleto_novo.agencia).to eql('4042')
    expect(boleto_novo.convenio).to eql(12_387_989)
    expect(boleto_novo.numero_documento).to eql('0777700168')
    expect(boleto_novo.carteira).to eql('17')
    expect(boleto_novo.codigo_servico).to be_falsey
    expect(boleto_novo.linha_digitavel).to eq('03399.27691 13100.000002 00000.101014 3 81000000001000')
    expect(boleto_novo.codigo_barras).to eq('03393810000000010009276913100000000000010101')
    expect(boleto_novo.nosso_numero_boleto).to eq('000123879890777700168')
  end

  it 'Calcular agencia_dv' do
    boleto_novo = described_class.new(@valid_attributes)
    boleto_novo.agencia = '85068014982'
    expect(boleto_novo.agencia_dv).to eql(9)
    boleto_novo.agencia = '05009401448'
    expect(boleto_novo.agencia_dv).to eql(1)
    boleto_novo.agencia = '12387987777700168'
    expect(boleto_novo.agencia_dv).to eql(2)
    boleto_novo.agencia = '4042'
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = '61900'
    expect(boleto_novo.agencia_dv).to eql(0)
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_dv).to eql(6)
    boleto_novo.agencia = 85_068_014_982
    expect(boleto_novo.agencia_dv).to eql(9)
    boleto_novo.agencia = 5_009_401_448
    expect(boleto_novo.agencia_dv).to eql(1)
    boleto_novo.agencia = 12_387_987_777_700_168
    expect(boleto_novo.agencia_dv).to eql(2)
    boleto_novo.agencia = 4042
    expect(boleto_novo.agencia_dv).to eql(8)
    boleto_novo.agencia = 61_900
    expect(boleto_novo.agencia_dv).to eql(0)
    boleto_novo.agencia = 719
    expect(boleto_novo.agencia_dv).to eql(6)
  end

  it 'Montar agencia_conta_boleto' do
    boleto_novo = described_class.new(@valid_attributes)

    expect(boleto_novo.agencia_conta_boleto).to eql('4042-8 / 00061900-0')
    boleto_novo.agencia = '0719'
    expect(boleto_novo.agencia_conta_boleto).to eql('0719-6 / 00061900-0')
    boleto_novo.agencia = '0548'
    boleto_novo.conta_corrente = '1448'
    expect(boleto_novo.agencia_conta_boleto).to eql('0548-7 / 00001448-6')
  end

  it 'Busca logotipo do banco' do
    boleto_novo = described_class.new
    expect(File.exist?(boleto_novo.logotipo)).to be_truthy
    expect(File.stat(boleto_novo.logotipo).zero?).to be_falsey
  end
end
