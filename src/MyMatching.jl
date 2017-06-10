module MyMatching

function my_deferred_acceptance(m_prefs, f_prefs)
#(m_prefs、f_prefs）を渡すとm_matchedとf_matchedが返る関数

m=length(m_prefs)
n=length(f_prefs)

#全ての要素が０の配列を作る
m_matched = zeros(Int64, m)
f_matched = zeros(Int64, n)

#男のインデックスと女のインデックスを渡すと、その男の順位が返ってくる関数（男が選好リストに入っていなければ０が返る）
function ranking(man ,woman)
    if !(man in f_prefs[woman])
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

count=zeros(Int64, m) #巡目と使われた選好リストとのずれをcountで表す
for j in 1:n #男性の選好リストの１巡目、2巡目…
    for i in 1:m #各男性が順に動く
        if all(m_matched.!=0) #もし男が全員マッチしていたら次の人に入らずmatchedを返す
            return m_matched, f_matched
        else
            if  j<=length(m_prefs[i])+count[i]
            #その男性が、マッチ済みで飛ばされた巡目を考慮したうえで、選好リストを使い切っていないならば
                if  m_matched[i]!=0
                    count[i]+=1 #既にマッチしている場合、プロポーズは行わず、ずれを１増やす
                else
                    like=m_prefs[i][j-count[i]]
                #iさんj巡目のプロポーズ相手をlikeと定義する（countは飛ばされた巡目を反映）
                    if ranking(i, like)!=0 #プロポーズ相手の女性の選好リストにiさんが載っている
                        if  f_matched[like]==0
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
end

return m_matched, f_matched

end
#関数の定義終了
export my_deferred_acceptance
end