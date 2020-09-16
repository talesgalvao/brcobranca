# -*- encoding: utf-8 -*-
# @author Kivanio Barbosa
module Brcobranca
  # Métodos auxiliares de cálculos envolvendo Datas.
  module CalculoData
    # Calcula o número de dias corridos entre a <b>data base ("Fixada" em 07.10.1997)</b> e a <b>data de vencimento</b> desejada.
    # @return [String] Contendo 4 dígitos
    # @example
    #  Date.parse(2000-07-04).fator_vencimento #=> 1001
    def fator_vencimento
      data_base = Date.parse '1997-10-07'
      fator_vencimento = Integer(self - data_base)

      while fator_vencimento > 9999
        data_base = data_base + 10000
        fator_vencimento = Integer(self - data_base) + 1000
      end

      fator_vencimento.to_s
    end

    # Mostra a data em formato <b>dia/mês/ano</b>
    # @return [String]
    # @example
    #  Date.today.to_s_br #=> 20/01/2010
    def to_s_br
      strftime('%d/%m/%Y')
    end
    # Calcula número de dias julianos.
    #
    # O cálculo é feito subtraindo-se a data atual, pelo último dia válido do ano anterior,
    # acrescentando-se o último algarismo do ano atual na quarta posição.
    #
    # @return [String] contendo 4 dígitos
    #
    # @example
    #  Date.parse(2009-02-11).to_juliano #=> "0429"
    def to_juliano
      ultima_data = Date.parse("#{year - 1}-12-31")
      ultimo_digito_ano = to_s[3..3]
      dias = Integer(self - ultima_data)
      (dias.to_s + ultimo_digito_ano).rjust(4, '0')
    end
  end
end

[Date].each do |klass|
  klass.class_eval { include Brcobranca::CalculoData }
end
