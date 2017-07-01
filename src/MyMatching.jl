module MyMatching

function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}},
                                caps::Vector{Int})

    m=length(prop_prefs)
    n=length(resp_prefs)

    #全ての要素が０の配列を作る
    prop_matches = zeros(Int64, m)
    resp_matches = zeros(Int64, sum(caps))

    indptr = Array{Int}(n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end

    #respのインデックスを渡すと、respとmatchしているpropの中で一番順位の低いpropが返る
    function worst(resp,j)
        worstrank=0
        worstindex=0
        for (index, prop) in enumerate(resp_matches[indptr[j]:indptr[j+1]-1])
            worstranknew=find(x->(x==prop),resp_prefs[resp])
            if worstranknew>worstrank
                worstrank=worstranknew
                worstindex=index
            end
        end
        return worst=(worstindex, resp_prefs[worstrank])
    end


    gap=zeros(Int64, m) #巡目と使われた選好リストとのずれをcountで表す
    for j in 1:n #propse側の選好リストの１巡目、2巡目…
        for i in 1:m #propose側が順に動く
            if all(prop_matches.!=0) #もし男が全員マッチしていたら次の人に入らずmatchedを返す
                return prop_matches, resp_matches, indptr
            else
                if  j<=length(prop_prefs[i])+gap[i]
                #その男性が、マッチ済みで飛ばされた巡目を考慮したうえで、選好リストを使い切っていないならば
                    if  prop_matches[i]!=0
                        gap[i]+=1 #既にマッチしている場合、プロポーズは行わず、ずれを１増やす
                    else
                        like=prop_prefs[i][j-gap[i]]
                    #iさんj巡目のプロポーズ相手をlikeと定義する（countは飛ばされた巡目を反映）
                        if i in resp_prefs[like] #プロポーズ相手の女性の選好リストにiさんが載っている
                            index=searchsortedfirst(-resp_matches[indptr[j]:indptr[j+1]-1],0)
                            if  index==1
                                prop_matches[i]=like
                                resp_matches[indptr[j+index-1]]=i
                        #女性に相手がいなければ、#マッチしているリストに追加
                            elseif
                                prop_matches[i]=like
                                prop_matches[worst(like,j)[2]]=0
                                resp_matches[indptr[j+worst(like,j)[1]-1]]=i
                        #既にマッチしている人より順位が高い（数字が小さい）とき、既にマッチしていた組を変更する
                            end
                        end
                    end
                end
            end
        end
    end

    return prop_matches, resp_matches, indptr

end
#関数の定義終了

function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}})
    caps = ones(Int, length(resp_prefs))
    prop_matches, resp_matches, indptr =
        my_deferred_acceptance(prop_prefs, resp_prefs, caps)
    return prop_matches, resp_matches
end

export my_deferred_acceptance
