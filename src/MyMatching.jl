module MyMatching

function my_deferred_acceptance(prop_prefs::Vector{Vector{Int}},
                                resp_prefs::Vector{Vector{Int}},
                                caps::Vector{Int})

    m=length(prop_prefs)
    n=length(resp_prefs)

    #全ての要素が０の配列を作る
    prop_matches = zeros(Int64, m)
    resp_matches = zeros(Int64, sum(caps))

    #indptrを作成
    indptr = Array{Int}(n+1)
    indptr[1] = 1
    for i in 1:n
        indptr[i+1] = indptr[i] + caps[i]
    end

    #respの番号とpropの番号を渡すと、respとmatchしているpropの中で一番順位の低いpropとそのindexが返る関数
    function worst(resp,i)
        worstrank=0 #respの選好の中での順位
        worstindex=0 #indptrの中でどこに格納されているか
        for (index, prop) in enumerate(resp_matches[indptr[resp]:indptr[resp+1]-1])
        #respがマッチ済みのpropに対して
            if prop!=0
            worstranknew=find(x->(x==prop),resp_prefs[resp])[1]
            #respの選好の中での順位
                if worstranknew>worstrank #順位が大きい（悪い）ならば変更する
                    worstrank=worstranknew
                    worstindex=index
                end
            end
        end

        if find(x->(x==i),resp_prefs[resp])[1]<worstrank
            return worstindex, resp_prefs[worstrank]
            #一番低いpropとそのindptr内での位置が返る
        else
            return 0
        end

    end


    gap=zeros(Int64, m) #巡目と使われた選好リストとのずれをgapで表す
    for j in 1:n #propse側の選好リストの１巡目、2巡目…
        for i in 1:m #propose側が順に動く
            if all(prop_matches.!=0) #もしproposerが全員マッチしていたら次の人に入らずmatchesを返す
                return prop_matches, resp_matches, indptr
            else
                if  j<=length(prop_prefs[i])+gap[i]
                #proposerが、マッチ済みで飛ばされた巡目を考慮したうえで、選好リストを使い切っていないならば
                    if  prop_matches[i]!=0
                        gap[i]+=1 #既にマッチしている場合、プロポーズは行わず、ずれを１増やす
                    else
                        like=prop_prefs[i][j-gap[i]]
                    #iさんj巡目のプロポーズ相手をlikeと定義する（gapは飛ばされた巡目を反映）
                        if i in resp_prefs[like] #プロポーズ相手の選好リストにiさんが載っている
                            index=searchsortedfirst(-resp_matches[indptr[like]:indptr[like+1]-1],0)
                        #respがcapacityを使い切っているか
                            if  index<=caps[like]
                                prop_matches[i]=like
                                resp_matches[indptr[like]+index-1]=i
                        #respがcapacityを使い切っていないなら、各々追加
                            
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

end