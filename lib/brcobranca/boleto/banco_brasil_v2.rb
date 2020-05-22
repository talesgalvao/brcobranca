module Brcobranca
  module Boleto
    class BancoBrasilV2 < BaseV2 # Banco do Brasil
      attr_accessor :codigo_barras
      attr_reader :linha_digitavel

      LINHA_DIGITAVEL_REGEXP = /^(.{5})(.{5})(.{5})(.{6})(.{5})(.{6})(.{1})(.{14})$/.freeze
      VALID_LINHA_DIGITAVEL_REGEXP = /^(\d{5})(\d{5})(\d{23})(\d{14})$/.freeze
      NOME_BANCO = 'bancobrasil'

      # Nova instancia do BancoBrasil
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        @codigo_barras = campos.dig(:codigo_barras)
        @linha_digitavel = campos.dig(:linha_digitavel)

        campos[:carteira] = '17'
        super(campos)
      end

      # Codigo do banco emissor (3 dígitos sempre)
      #
      # @return [String] 3 caracteres numéricos.
      def banco
        '001'
      end

      # Carteira
      #
      # @return [String] 2 caracteres numéricos.
      def carteira=(valor)
        @carteira = valor.to_s.rjust(2, '0') if valor
      end

      # Dígito verificador do banco
      #
      # @return [String] 1 caracteres numéricos.
      def banco_dv
        banco.modulo11_9to2_10_como_x
      end

      # Retorna dígito verificador da agência
      #
      # @return [String] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11_9to2_10_como_x
      end

      # Conta corrente
      # @return [String] 8 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(8, '0') if valor
      end

      # Dígito verificador da conta corrente
      # @return [String] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11_9to2_10_como_x
      end

      # Número seqüencial utilizado para identificar o boleto.
      def numero_documento
        @numero_documento.to_s.rjust(10, '0')
      end

      # Dígito verificador do nosso número.
      # @return [String] 1 caracteres numéricos.
      # @see BancoBrasil#numero_documento
      def nosso_numero_dv
        "#{convenio}#{numero_documento}".modulo11_9to2_10_como_x
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "12387989000004042-4"
      def nosso_numero_boleto
        "000#{convenio}#{numero_documento}"
      end

      # Agência + conta corrente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0548-7 / 00001448-6"
      def agencia_conta_boleto
        "#{agencia}-#{agencia_dv} / #{conta_corrente}-#{conta_corrente_dv}"
      end

      def linha_digitavel=(linha_digitavel_bb)
        unless linha_digitavel_bb =~ VALID_LINHA_DIGITAVEL_REGEXP
          raise ArgumentError, "#{linha_digitavel_bb} Linha digitável precisa conter 47 caracteres numéricos."
        end

        @linha_digitavel = linha_digitavel_bb.gsub(LINHA_DIGITAVEL_REGEXP, '\1.\2 \3.\4 \5.\6 \7 \8')
      end

      def nosso_numero_boleto=(nosso_numero_bb)
        ultima_posicao_nosso_numero_str = nosso_numero_bb.size - 1
        nosso_numero_str = String.new(nosso_numero_bb)

        @nosso_numero_boleto = nosso_numero_str.insert(ultima_posicao_nosso_numero_str, '-')
      end
    end
  end
end
