module MyMatching

export my_deferred_acceptance

function my_deferred_acceptance(m_prefs, f_prefs)
#(m_prefs、f_prefs）を渡すとm_matchedとf_matchedが返る関数

m=length(m_prefs)
n=length(f_prefs)

#全ての要素が０の配列を作る
m_matched=Array{Int64}(m)
f_matched=Array{Int64}(n)
m_matched[:]=0
f_matched[:]=0

#男のインデックスと女のインデックスを渡すと、その男の順位が返ってくる関数（男が選好リストに入っていなければ０が返る）
function ranking(man ,woman)
    if !(any(man in f_prefs[woman][i] for i in 1:length(f_prefs[woman])))
        return 0
    #女性の選好の中に男性が入っていなければ０を返す
    else
        for i in 1:length(f_prefs[woman])
            if f_prefs[woman][i]==man
                return i
    #女性からの男性の順位を返す
            end
        end
    end
end


for j in 1:n
#男性の選好リストの１巡目、2巡目…
    for i in 1:m
        #各男性が順に動く
        if n>m&&all(m_matched.!=0)
        #もし既に男女のどちらかが全員マッチしていたら次の人に入らずmatchedを返す
            break
            return m_matched, f_matched
        else
            if j<=length(m_prefs[i])&&m_matched[i]==0
            #ある男性がj巡目に、まだ選好を持ち、相手がいない
                like=m_prefs[i][j]
                #iさんj巡目のプロポーズ相手をlikeと定義する

                if ranking(i, like)!=0
                #プロポーズ相手の女性の選好リストにiさんが載っている
                    if f_matched[like]==0
                        m_matched[i]=like
                        f_matched[like]=i
                    #女性に相手がいなければ、#マッチしているリストに追加
                    elseif ranking(i, like)<ranking(f_matched[like],like)
                        m_matched[f_matched[like]]=0
                        m_matched[i]=like
                        f_matched[like]=i
                    #既にマッチしている人より順位が高い（数字が小さい）とき、既にマッチしていた組を変更する
                    end
                end
            end
        end
    end
end

return m_matched, f_matched

end
#関数の定義終了

end