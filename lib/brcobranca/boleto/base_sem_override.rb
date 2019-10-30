# frozen_string_literal: true

module Brcobranca
  module Boleto
    # Classe base para todas as classes de boletos
    class BaseSemOverride
      extend Template::Base

      # Configura gerador de arquivo de boleto e código de barras.
      extend define_template(Brcobranca.configuration.gerador)
      include define_template(Brcobranca.configuration.gerador)

      # Validações do Rails 3
      include ActiveModel::Validations

      # <b>REQUERIDO</b>: Número do convênio/contrato do cliente junto ao banco emissor
      attr_accessor :convenio
      # <b>REQUERIDO</b>: Tipo de moeda utilizada (Real(R$) e igual a 9)
      attr_accessor :moeda
      # <b>REQUERIDO</b>: Carteira utilizada
      attr_accessor :carteira
      # <b>OPCIONAL</b>: Variacao da carteira(opcional para a maioria dos bancos)
      attr_accessor :variacao
      # <b>OPCIONAL</b>: Data de processamento do boleto, geralmente igual a data_documento
      attr_accessor :data_processamento
      # <b>REQUERIDO</b>: Número de dias a vencer
      attr_accessor :dias_vencimento
      # <b>REQUERIDO</b>: Quantidade de boleto(padrão = 1)
      attr_accessor :quantidade
      # <b>REQUERIDO</b>: Valor do boleto
      attr_accessor :valor
      # <b>REQUERIDO</b>: Número da agencia sem <b>Digito Verificador</b>
      attr_reader :agencia
      # <b>REQUERIDO</b>: Número da conta corrente sem <b>Digito Verificador</b>
      attr_reader :conta_corrente
      # <b>REQUERIDO</b>: Nome do proprietario da conta corrente
      attr_accessor :cedente
      # <b>REQUERIDO</b>: Endereço do proprietario da conta corrente
      attr_accessor :cedente_endereco
      # <b>REQUERIDO</b>: Documento do proprietario da conta corrente (CPF ou CNPJ)
      attr_accessor :documento_cedente
      # <b>OPCIONAL</b>: Número sequencial utilizado para identificar o boleto
      attr_accessor :numero_documento
      # <b>REQUERIDO</b>: Símbolo da moeda utilizada (R$ no brasil)
      attr_accessor :especie
      # <b>REQUERIDO</b>: Tipo do documento (Geralmente DM que quer dizer Duplicata Mercantil)
      attr_accessor :especie_documento
      # <b>REQUERIDO</b>: Data em que foi emitido o boleto
      attr_accessor :data_documento
      # <b>OPCIONAL</b>: Código utilizado para identificar o tipo de serviço cobrado
      attr_accessor :codigo_servico
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao1
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao2
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao3
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao4
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao5
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao6
      # <b>OPCIONAL</b>: Utilizado para mostrar alguma informação ao sacado
      attr_accessor :instrucao7
      # <b>REQUERIDO</b>: Informação sobre onde o sacado podera efetuar o pagamento
      attr_accessor :local_pagamento
      # <b>REQUERIDO</b>: Informa se o banco deve aceitar o boleto após o vencimento ou não( S ou N, quase sempre S)
      attr_accessor :aceite
      # <b>REQUERIDO</b>: Nome da pessoa que receberá o boleto
      attr_accessor :sacado
      # <b>OPCIONAL</b>: Endereco da pessoa que receberá o boleto
      attr_accessor :sacado_endereco
      # <b>REQUERIDO</b>: Documento da pessoa que receberá o boleto
      attr_accessor :sacado_documento

      # Validações
      validates_presence_of :agencia, :conta_corrente, :moeda, :especie_documento, :especie,
                            :aceite, :numero_documento, :cedente_endereco, :carteira,
                            message: 'não pode estar em branco.'
      validates_numericality_of :convenio, :agencia, :conta_corrente,
                                :numero_documento, message: 'não é um número.', allow_nil: true

      NOME_BANCO = 'santander'

      # Nova instancia da classe Base
      # @param [Hash] campos
      def initialize(campos = {})
        padrao = {
          moeda: '9', data_documento: Date.today, dias_vencimento: 1, quantidade: 1,
          especie_documento: 'DM', especie: 'R$', aceite: 'S', valor: 0.0,
          local_pagamento: 'QUALQUER BANCO ATÉ O VENCIMENTO'
        }

        campos = padrao.merge!(campos)
        campos.each do |campo, valor|
          send "#{campo}=", valor
        end

        yield self if block_given?
      end

      # Logotipo do banco
      # @return [Path] Caminho para o arquivo de logotipo do banco.
      def logotipo
        File.join(File.dirname(__FILE__), '..', 'arquivos', 'logos', "#{NOME_BANCO}.eps")
      end

      # @return [String] Informações adicionar no recibo do pagador.
      def info_recibo_pagador
        ''
      end

      # Dígito verificador do banco
      # @return [Integer] 1 caracteres numéricos.
      def banco_dv
        banco.modulo11_9to2
      end

      # Código da agencia
      # @return [String] 4 caracteres numéricos.
      def agencia=(valor)
        @agencia = valor.to_s.rjust(4, '0') if valor
      end

      # Dígito verificador da agência
      # @return [Integer] 1 caracteres numéricos.
      def agencia_dv
        agencia.modulo11_9to2
      end

      # Dígito verificador da conta corrente
      # @return [Integer] 1 caracteres numéricos.
      def conta_corrente_dv
        conta_corrente.modulo11_9to2
      end

      # Carteira para exibição no boleto gerado
      # @return [String]
      def carteira_boleto
        carteira
      end

      # Valor total do documento: <b>quantidate * valor</b>
      # @return [Float]
      def valor_documento
        quantidade.to_f * valor.to_f
      end

      # Data de vencimento baseado na <b>data_documento + dias_vencimento</b>
      #
      # @return [Date]
      # @raise [ArgumentError] Caso {#data_documento} esteja em branco.
      def data_vencimento
        unless data_documento
          raise ArgumentError, 'data_documento não pode estar em branco.'
        end
        return data_documento unless dias_vencimento

        (data_documento + dias_vencimento.to_i)
      end

      # Fator de vencimento calculado com base na data de vencimento do boleto.
      # @return [String] 4 caracteres numéricos.
      def fator_vencimento
        data_vencimento.fator_vencimento
      end

      # Número da conta corrente
      # @return [String] 7 caracteres numéricos.
      def conta_corrente=(valor)
        @conta_corrente = valor.to_s.rjust(7, '0') if valor
      end

      attr_writer :custom_fields

      def custom_fields
        @custom_fields || {}
      end

      private

      # Valor total do documento
      # @return [String] 10 caracteres numéricos.
      def valor_documento_formatado
        valor_documento.round(2).limpa_valor_moeda.to_s.rjust(10, '0')
      end

      # Nome da classe do boleto
      # @return [String]
      def class_name
        self.class.to_s.split('::').last.downcase
      end
    end
  end
end
