# -*- encoding: utf-8 -*-
module Brcobranca
  module Boleto
    class Citibank < Base
      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :numero_documento, maximum: 11, message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 8, message: 'deve ser menor ou igual a 8 dígitos.'
      validates_length_of :carteira, maximum: 3, message: 'deve ser menor ou igual a 3 dígitos.'

      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '113' }.merge!(campos)
        super(campos)

        @conta_cosmo = "%010d" % conta_corrente
      end

      # Codigo do banco emissor (3 dígitos sempre)
      # @return [String] 3 caracteres numéricos.
      def banco
        '745'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Número seqüencial utilizado para identificar o boleto.
      # @return [String] 11 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(11, '0') if valor
      end

      def nosso_numero_dv
        numero_documento.modulo11_9to2_10_como_zero
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> ""06/00000004042-8"
      def nosso_numero_boleto
        "#{carteira}/#{numero_documento}-#{nosso_numero_dv}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 00001448-6"
      def agencia_conta_boleto
        "#{agencia}-#{agencia_dv} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      def portifolio
        convenio.split(//).last(3).join
      end

      def conta_cosmo_base
        @conta_cosmo[1..6]
      end

      def conta_cosmo_sequencia
        @conta_cosmo[7..8]
      end

      def conta_cosmo_dv
        @conta_cosmo[9]
      end

      # Segunda parte do código de barras.
      #
      # Posição | Tamanho | Conteúdo
      # 20        1         Código do Produto 3 - Cobrança com registro / sem registro
      # 21 a 23   3         3 últimos dígitos do campo de identificação da empresa no CITIBANK (Posição 44 a 46 do arquivo retorno)
      # 24 a 29   6         Base
      # 30 a 31   2         Sequência
      # 32        1         Dígito Conta Cosmos
      # 33 a 44   12        Nosso Número
      # @return [String] 25 caracteres numéricos.
      def codigo_barras_segunda_parte
        "3#{portifolio}#{conta_cosmo_base}#{conta_cosmo_sequencia}#{conta_cosmo_dv}#{numero_documento}#{nosso_numero_dv}"
      end
    end
  end
end
