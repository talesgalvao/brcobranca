RSpec.describe Brcobranca::CalculoData do
  describe '#fator_vencimento' do
    it 'Calcula o fator de vencimento' do
      expect((Date.parse '2008-02-01').fator_vencimento).to eq('3769')
      expect((Date.parse '2008-02-02').fator_vencimento).to eq('3770')
      expect((Date.parse '2008-02-06').fator_vencimento).to eq('3774')
      expect((Date.parse '03/07/2000').fator_vencimento).to eq('1000')
      expect((Date.parse '04/07/2000').fator_vencimento).to eq('1001')
      expect((Date.parse '05/07/2000').fator_vencimento).to eq('1002')
      expect((Date.parse '01/05/2002').fator_vencimento).to eq('1667')
      expect((Date.parse '17/11/2010').fator_vencimento).to eq('4789')
      expect((Date.parse '21/02/2025').fator_vencimento).to eq('9999')
      expect((Date.parse '22/02/2025').fator_vencimento).to eq('1000')
      expect((Date.parse '23/02/2025').fator_vencimento).to eq('1001')
    end
  end
end
