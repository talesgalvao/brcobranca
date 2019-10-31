# frozen_string_literal: true

module Brcobranca
  module Boleto
    class SantanderComRepasseDeRegras < BaseSemOverride
      attr_accessor :seu_numero, :codigo_cedente, :codigo_barras
      attr_reader :linha_digitavel, :nosso_numero_boleto

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, maximum: 9, message: 'deve ser menor ou igual a 9 dígitos.'
      validates_length_of :seu_numero, maximum: 15, message: 'deve ser menor ou igual a 15 dígitos.'
      validates_length_of :nosso_numero_boleto, maximum: 13,
                                                message: 'deve ser menor ou igual a 13 digitos'

      LINHA_DIGITAVEL_REGEXP = /^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/.freeze
      VALID_LINHA_DIGITAVEL_REGEXP = /^(\d{5})(\d{5})(\d{23})(\d{14})$/.freeze

      # Nova instancia do SantanderComRepasseDeRegras
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        @codigo_cedente = campos.dig(:codigo_cedente)
        @nosso_numero_boleto = campos.dig(:nosso_numero_boleto)
        @codigo_barras = campos.dig(:codigo_barras)
        @linha_digitavel = campos.dig(:linha_digitavel)

        campos[:carteira] = campos.fetch(:carteira) { '' }
        campos[:conta_corrente] = campos.fetch(:conta_corrente) { '' }

        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '033'
      end

      # Número do convênio/contrato do cliente junto ao banco. No Santander, é
      # chamado de Código do Cedente.
      # @return [String] 7 caracteres numéricos.
      def convenio
        codigo_cedente
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/1899775"
      def agencia_conta_boleto
        "#{agencia}/#{convenio}"
      end

      def linha_digitavel=(text)
        unless text =~ VALID_LINHA_DIGITAVEL_REGEXP
          raise ArgumentError, "#{text} Linha digitável precisa conter 47 caracteres numéricos."
        end

        @linha_digitavel = text.gsub(LINHA_DIGITAVEL_REGEXP, '\1.\2 \3.\4 \5.\6 \7 \8')
      end

      def nosso_numero_boleto=(nosso_numero_santander)
        ultima_posicao_nosso_numero_str = nosso_numero_santander.size - 1
        nosso_numero_str = String.new(nosso_numero_santander)

        @nosso_numero_boleto = nosso_numero_str.insert(ultima_posicao_nosso_numero_str, '-')
      end
    end
  end
end
