# -*- encoding: utf-8 -*-
# @author Laerte Guimarães
module Brcobranca
  module Boleto
    class SantanderWebService < Base # Banco Santander c/ registro online
      # Usado somente em carteiras especiais com registro para complementar o número do documento
      attr_reader :seu_numero

      validates_length_of :agencia, maximum: 4, message: 'deve ser menor ou igual a 4 dígitos.'
      validates_length_of :convenio, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'
      validates_length_of :numero_documento, maximum: 12, message: 'deve ser menor ou igual a 12 dígitos.'
      validates_length_of :seu_numero, maximum: 7, message: 'deve ser menor ou igual a 7 dígitos.'

      # Nova instancia do Santander
      # @param (see Brcobranca::Boleto::Base#initialize)
      def initialize(campos = {})
        campos = { carteira: '102',
                   conta_corrente: '00000' # Obrigatória na classe base
                  }.merge!(campos)
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
      def convenio=(valor)
        @convenio = valor.to_s.rjust(7, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      # @return [String] 12 caracteres numéricos.
      def numero_documento=(valor)
        @numero_documento = valor.to_s.rjust(12, '0') if valor
      end

      # Número sequencial utilizado para identificar o boleto.
      # @return [String] 7 caracteres numéricos.
      def seu_numero=(valor)
        @seu_numero = valor.to_s.rjust(7, '0') if valor
      end

      # Nosso número para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.nosso_numero_boleto #=> "000090002720-7"
      def nosso_numero_boleto
        numero_documento = numero_documento.to_s.rjust(13, '0') unless numero_documento.nil?
        nosso_numero = numero_documento[0..11]
        nosso_numero_dv = numero_documento[12]

        "#{nosso_numero}-#{nosso_numero_dv}"
      end

      # Agência + codigo do cedente do cliente para exibir no boleto.
      # @return [String]
      # @example
      #  boleto.agencia_conta_boleto #=> "0059/1899775"
      def agencia_conta_boleto
        "#{agencia}/#{convenio}"
      end

      def codigo_barras
        # TODO
      end
    end
  end
end
