# frozen_string_literal: true

module Brcobranca
  module Boleto
    # Classe que repassa as regras de negocio implementadas em fontes externas.
    class CitibankV2 < BaseV2
      attr_accessor :codigo_barras
      attr_reader :linha_digitavel

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :numero_documento, maximum: 11, message: 'deve ser menor ou igual a 11 dígitos.'
      validates_length_of :conta_corrente, maximum: 10, message: 'deve ser menor ou igual a 10 dígitos.'
      validates_length_of :carteira, maximum: 3, message: 'deve ser menor ou igual a 3 dígitos.'

      LINHA_DIGITAVEL_REGEXP = /^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/.freeze
      VALID_LINHA_DIGITAVEL_REGEXP = /^(\d{5})(\d{5})(\d{23})(\d{14})$/.freeze

      # Nova instancia do CibankComRepasseDeRegras
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        @codigo_barras = campos.dig(:codigo_barras)
        @linha_digitavel = campos.dig(:linha_digitavel)

        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
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

      def linha_digitavel=(text)
        unless text =~ VALID_LINHA_DIGITAVEL_REGEXP
          raise ArgumentError, "#{text} Linha digitável precisa conter 47 caracteres numéricos."
        end

        @linha_digitavel = text.gsub(LINHA_DIGITAVEL_REGEXP, '\1.\2 \3.\4 \5.\6 \7 \8')
      end
    end
  end
end
