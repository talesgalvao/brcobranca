# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Brcobranca::Boleto::BtgPactual do
  describe '#codigo_barras' do
    let(:valid_attributes) do
      {
        agencia: '0050',
        conta_corrente: '445757',
        carteira: '1',
        numero_documento: '123',
        data_documento: Date.new(2025, 2, 20),
        dias_vencimento: 3,
        valor: 123.45
      }
    end

    subject(:boleto_novo) do
      described_class.new(valid_attributes)
    end

    it 'retorna o código do banco nas posições 1 a 3' do
      expect(boleto_novo.codigo_barras[0..2]).to eq('208')
    end

    it 'retorna o código da moeda na posições 4' do
      expect(boleto_novo.codigo_barras[3]).to eq('9')
    end

    it 'retorna dígito verificador do código de barras na posição 5' do
      expect(boleto_novo.codigo_barras[4]).to eq('8')
    end

    it 'retorna o fator de vencimento nas posições 6 a 9' do
      expect(boleto_novo.codigo_barras[5..8]).to eq('1001')
    end

    it 'retorna o valor nas posições 10 a 19' do
      expect(boleto_novo.codigo_barras[9..18]).to eq('0000012345')
    end

    it 'retorna o código da agência nas posições 20 a 23' do
      expect(boleto_novo.codigo_barras[19..22]).to eq('0050')
    end

    it 'retorna o código da agência nas posições 24 a 25' do
      expect(boleto_novo.codigo_barras[23..24]).to eq('01')
    end

    it 'retorna o nosso número nas posições 26 a 36' do
      expect(boleto_novo.codigo_barras[25..35]).to eq('00000000123')
    end

    it 'retorna a conta do beneficiário nas posições 37 a 43' do
      expect(boleto_novo.codigo_barras[36..42]).to eq('0445757')
    end

    it 'retorna um zero fixo na posição 44' do
      expect(boleto_novo.codigo_barras[43]).to eq('0')
    end
  end

  describe '#agencia_conta_boleto' do
    let(:valid_attributes) do
      {
        agencia: '0050',
        conta_corrente: '445757',
        carteira: '1',
        numero_documento: '123',
        data_documento: Date.new(2025, 2, 20),
        dias_vencimento: 3,
        valor: 123.45
      }
    end

    subject(:boleto_novo) do
      described_class.new(valid_attributes)
    end

    it 'retorna a agência e conta corrente do boleto' do
      expect(boleto_novo.agencia_conta_boleto).to eq('0050 / 0445757-9')
    end
  end

  describe '#nosso_numero_boleto' do
    let(:valid_attributes) do
      {
        agencia: '0050',
        conta_corrente: '445757',
        carteira: '1',
        numero_documento: '123',
        data_documento: Date.new(2025, 2, 20),
        dias_vencimento: 3,
        valor: 123.45
      }
    end

    subject(:boleto_novo) do
      described_class.new(valid_attributes)
    end

    it 'retorna a agência e conta corrente do boleto' do
      expect(boleto_novo.nosso_numero_boleto).to eq('123')
    end
  end
end
