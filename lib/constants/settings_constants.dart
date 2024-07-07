import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/transportation_mode.dart';

const String kUnitsIsMetricKey = "isMetric";

final kSamplePostJson2 = {
  "_id": "1",
  "title": "This is another sample post",
  "description": "",
  "routeId": {
    "_id": "1",
    "title": "test2",
    "type": "mb",
    "route": {
      "distance": 29883.931,
      "weight": 939706.052966,
      "time": 8045685,
      "transfers": 0,
      "points_encoded": true,
      "bbox": [-72.909028, 41.307276, -72.838429, 41.375987],
      "points":
          "chi{Fng~{LwyETiDfE\\H?NLgE?MfEES?S[?ME?d@cHvj@sC]wQgAB?EoCnKEY?EE?sFoB_q@[vB?QrBoKGpA?{DLgEDcEoKDc@?Lo@?Ts@?\\k@~W^}@?oAy@?sK_DgE{AQf^iAU?}@a@_Xo@_@?}Bi@nKaAI?aCc@fEi@O?WK?UW?Sa@?eCy@wQ}EsAnKjAaI~p@cCi@oKqC{@vQUjAoKs@fA?UOoKcAU?OA?MB?ON?ET?O~AoKe@|DgE_B`HgEcCoAvQcAdE_jA{QoJ?Oh@oKIP?w@d@oKML?EP?QjAgEaEs@gEqCc@oKI@?OJ?EJ?Ox@oKkEuAfEXwA?~AoKn}@eG_DoK@Q?QgA?E_Af^rBiA?Xg@fEH[vQdAyGvQ@a@nKK[?IK?IE?i@??m@EfEoE_Aod@q@E?OU?Oc@vQOiC?Ea@~p@GW?_@_@?UI?kGWoKC{A~p@SoDvj@?_@?NsBf^wGuA?Qx@?eAQoKSN??i@?s@G?]??Ba@?_Ik@?|AsX~Wn@{LfEj@_JgEl@eIgEb@sNfE@{CgECsAnKo@oPwQEeC_X?sK?Aa@wQEk@?TM?rJaN?cCgDfEuC_DfEc@m@gEk@gA?i@q@?a@]?i@UoKi@M?\\wE~W@w@wQAo@?K_BoKQmA?gA}E~Wm@mBoKcBqD?{CqFwQ]s@?[eA?e@mCgEyAsJfEOqAfEAU?yCKgE^iOoKR}PgEcIQvQqG^fEm@J?{AkTod@q@yJfEaAyQo}@hAPvQlPnEf^`K`CfEjBZnKdAb@?z@d@?VR?`@b@~W|C`EgEJX?VbA?Rb@?`BjCgEN\\?P|@wQBb@?EhCgEKxD~WMxCfE?^?hJ\\fw@VA?hAQ?z@Y?f@K?pEGoKTB?pCTwQC`D?CtIwQpBD?lAL?lAh@fEhAbAwQThAgEElCfElCHg^v@LnKn@R?j@VnKvDpCfEf@XwQz@`@?fBTwQfO|@wQtIp@wQXf@?jI~Uf^`A`CnKtFvP~p@pA_A?^O?^E?tAA?vCDgEAr@?DpA?`Ee@~W|@cBg^~GuCwQIu@?Dq@?Pi@?TYnK^W?RU?`AM?y@cA_XnB{BoKt@oA_Xh@i@?f@M?VQod@PQwQZg@?LW?v@iA?\\]_q@FM?@Ood@DG?HC?j@E?@Q?n@r@?NF?~ABwj@zB^vQBE?RK?FI?^u@_XvAwA?~@i@gpAhA_@?ZW?Bc@?DM??K?E_@gEKk@_XAo@?C]?DS?TYvQl@kA?Pm@?TwAod@Xu@?HY?Hi@od@Bq@?HS?VWnd@q@q@od@SW_XQg@?KO?YQ?cAqAovAaAaAgENa@?Ze@?J_@?NKwj@Jk@vj@LE?XR?XE?JU?NC?LI?XA?LG?BK??O?AE?E???o@wQPAfpAHE?HE?HS?BM?AO?EU?QM?OCgpAaAG?GG??G?DI?h@Yfw@PQ?BS?KqA?vAQnKhAA?hBh@v|AzC~Cnd@rBlFgEx@bB?b@t@?d@b@?f@^fEt@^?lAT?vFB~W|@F?VF?nAj@~WhApAoKPZ?f@~AvQj@xB?p@vA_XfDjEvQr@bAvj@fA~@vQfBbAnd@tBfBoKv@^nd@KfAoKxCt@fEr@L?f@I?TK?ZW?d@fAwQBZ?I~@fEmAhHnK|JnDwj@gCjO~iA|FnBf^bB^wQzMpCn}@tCd@nKt@TfEbAT?h@H?f@AgEHt@?P|E?LfB?P|@fEdAhD?Hv@oKD^?HZ?K|A~WIpCoKKfAvj@Qr@?Wj@?OJ?_@L?RfD~WFxCf^ElB?GfAvQt@Y?HI?PtA?DRvQCh@_XVA~WbB]?b@C?v@FoKzGrCgE`GtAfEfGnBnK@ZfEFf@?hAtDoKj@lFgExGZod@|S`Cgw@_@lE_q@Er@?ExA?@r@od@Dd@?Rv@?PX?vAfB_q@hCtDvQHTfEDZnKDrC?Mz@~p@{AlDfw@?h@?HH?jFhC?gBnGf^{AxEvcAoAxD~WsBxG_XY|@?If@?I|Cwj@FnCnK{TlCg^wDj@fEaTjDfERnC?_En@?vBhYwQw@LfEeANfE_A??a@M?WWoKwAnCvQo@rAgENR?cCbGgEfC|BoKET?_C~Ff^EF?I??wIgEg^qCwAgw@KC??G?qAU?cAi@?s@M?m@o@ooBIE?S?_XmAZ~iAKF?MN?C??AI?DG?fAuA_jA^]?I]?CY?GSgE@}@?HQ?DE?NA_q@h@J?|@@?XF?^P?ZC?PG?`@_@?R]?Hc@~WHk@?Ae@?CO?IS?MK?m@A?AO?EC?i@E~WgA@?q@OnvAKS?GE?gA^nd@c@D?EL_q@]f@?c@`@?i@\\~p@e@D?eAO?o@Dod@_AC?Q@?q@P?g@RnKw@j@wuBOH?yAXfw@u@l@?_AjAo}@Wd@fiBIR?WjA?CZfEBf@?@xB_XG`@?S|@?]N?_CPvQk@J?aBf@wj@q@f@?kAr@?SRv|A[dCgpA@T?T^?@H_jACV?K\\?EX?Fb@?@V?MF?q@J?IFgpAGP?OC?OM?U@?_@b@vQQA?SD?[T?k@Z?SR?M?f^{@M?U??SH?[V?KB?EE?IM?Kg@fEIG?WM?SO?_@D?CC?MW?MM?k@Qnd@_@Y?QE?_@L?c@U?uAiAwcAUI?}@G?{@FoKWA?_@@?m@N?c@@?]Cf^iAe@?c@KfpA_@E?sAAnKi@B?GRwcA?d@?k@BfpAa@H?e@V?c@^?U\\?Qf@gw@SjAvcAIV?M~@?HB?At@?PfA?J\\wQPZ?PP?dAvA?l@XfiBb@d@ooB\\fB?r@x@~iAy@^?_At@n}@i@r@vj@WT?OF?]Z?ID?KR?_@ZgEKA?{@_@?`BuGo}@BU??S?Ic@?MOf^uHiFo}@V}CwQ",
      "legs": [],
      "ascend": 664,
      "descend": 664,
      "snapped_waypoints": "chi{Fng~{LwyEczEu`KnvAbzEt`KovA"
    },
    "imageUrl":
        "https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/path-5+ff0000-1.0(chi%7BFng~%7BLr%40_DN%3FYo%40ViH%7BEYKiDyFuBm%40jFcE~AJgFb%40cB%7C%40iBcNyEeDg%40mBaA_Es%40kDs%40m%40c%40yC%7BAqCuKuGeBiArCyAe%40%5D%40Ud%40u%40%7CGcFpE_TiDYz%40eAr%40W%7CAsIwAYLUdAqDmDeDoPOyAlBiCb%40cAfA%7BHUg%40s%40E%7DFeAaA%5B_%40mDMy%40u%40i%40oGsBSoEgGiEwAf%40SYqAG%7BHmAlCof%40xAeTd%40oSs%40cSEyOGmAhKoNyGgIoAuBkAoAsAc%40%5EoGMoCyAkHqC_HyDeHaAsEiBeM%7BCa%40r%40ga%40uQLiC_TsBs%5DvR%60FlN%7CC%60ChAx%40v%40hDzEj%40fBpBhDT%60BQbIMxD%60KZdCk%40xFSfDXGvN~DRvClBNvEdEVzAj%40~EjDbDv%40%7CYnBdJfWvHxTpBoAtBGtCx%40fEj%40%7CIyFCgBf%40cAr%40m%40FqAdDkEpAw%40h%40c%40h%40_AtAgBH%5DNKl%40W~%40z%40zEb%40VQf%40_AvCaCdBw%40Hq%40Ek%40M%7BA%40q%40bAeBf%40eCb%40oAL%7BA%60%40k%40eAiA%5Dw%40%7DAcBq%40cBf%40eAZw%40f%40Ld%40%5B%5CMf%40IB%5BGEPq%40RKLa%40Ge%40a%40QiAODQz%40k%40GeB%60DSdGhElDpIhAxA%7CA~%40dIXtANxC%7CBx%40zB%7CApEzEnGnDbClDfClC%7CBzABp%40c%40h%40bBwAhJtFzT%60JnCpRvDxBj%40pAFZrG%5EdDnA%60FNz%40UnF%5DzBg%40v%40KtD%40fGl%40l%40ZjA%40%7C%40zB_%40zAB%7COhFhGjCpA%7CEdIhG%7CRnIKlCFxAd%40pA%60F%7CGNp%40GnE%7BAvEtFrCcEhNcErMc%40dBAlHsZxDmSzHgAxZ%7DB%5CaBMoBvB_%40fBB%60KeCtGOFiN_HKKuC_AaB%7D%40%5DEyAb%40QNBQfBsBMw%40EqANWx%40HvAHz%40Lr%40g%40%5CaAFqAMc%40%7B%40MGSqBC%7D%40c%40oAXi%40RaAhAoAb%40uBIqAAyAd%40gAt%40oCfAwApBa%40~A%3FbAEzCq%40lAkD%5CsCnA_BfAYzCVh%40Ot%40%40%7C%40K%5E%7B%40RWLe%40Kq%40%60%40o%40Z_An%40iAMi%40Hg%40ZOSUo%40k%40%5Dc%40%40%5Be%40kAk%40q%40FyB_BsAQsADmAPaAAmBq%40sBGq%40Vk%40h%40gA%60%40y%40%7C%40e%40rBWvAFx%40%5CdBb%40l%40rBpB%60AlCExAiBhBg%40%5Cg%40%60%40k%40n%40gAa%40dBkHIw%40cIyF)/auto/1200x700?access_token=$kMapboxAccessToken",
    "routeOptions": {
      "profile": TransportationMode.gravel_cycling.value,
      "waypoints": []
    },
    "__v": 0
  },
  "likes": 1117,
};

final kSamplePostJson1 = {
  "_id": "1",
  "title": "This is a sample post",
  "description": "",
  "routeId": {
    "_id": "1",
    "title": "Test route 1",
    "type": "gh",
    "route": {
      "distance": 19613.678,
      "weight": 31589697.699637,
      "time": 9737283,
      "transfers": 0,
      "points_encoded": true,
      "bbox": [-117.838608, 33.885128, -117.732688, 33.920948],
      "points":
          "ac_nEt}dnUwvb@XM?bAW~WpAK?LD?DP?BjA?Z`Bnd@pAc@vj@Tt@?BL?d@bAnvAXN?NT?Xx@g^PR?N`@?BR~WA|A?CL?CL?q@p@f^U^?G`@??pBvQDP??N?OO?m@_BwQc@m@?IO??a@?Gk@?EK?UOod@U_@?EA?MJ?Md@?Yl@~p@IR?QZ?MD?GH??R?JZ?Ah@vQy@jEgw@O^?Ef@??t@~p@Nx@?@Z?a@tAn}@BL?FH?n@\\fEBH?AJ?Sb@gEGX?G`@vQGF?KD?u@a@wQ]G?u@@?gAS?g@O?WO?OUgEEY?Bg@?@{@oKCiB?CQgEo@{A?KO?i@S?YC?QE?a@W~WSSoKs@g@?w@_@?g@KfEUI?sAeBgEg@aAgEOq@?]_AoKg@_CfEIk@?S[?Kq@?Wc@od@}@g@fEMS?KW?E_@?@U?FUnK^_@?FM?Fi@?@]?GuAoKB_@?F_@?L]?LKgw@L_@nd@N}@?AM?CG?_@]fEKO?Cc@oKEA?K@?GF?EJnKQ??KGoKAG?Rk@?x@kA?JYnK?MgEEG_XU??OD?QO?oBA?CG?@O?~@??R]?f@i@?Ds@nKJI?Oi@?AS?D_@?KW?Ag@oKHm@?FQ?P[?p@m@vQXC?DG?LcAgE@]?E]?KG?G@?WK?x@mD_XN{@gENQ?PS?fC_Cf^`@M?N??XDwj@rCr@nKn@JvQPC?n@m@_q@f@y@?\\eAvQj@yBod@b@mCwj@Pq@?b@k@?XeAn}@LK?NG?x@C?jAk@_cBp@e@~bB\\u@?JqA?XkA_XL_Bod@d@iCg^H_@f^Rc@?Di@?@I?f@qEvQA_BoK@i@?Lu@?@k@wQPeB?JcC_XFs@?Be@fEEm@?WuB?EgB?I]?_@_AgEGa@??kCwQDyA?Aq@wQGy@?]}AoKCY?Bq@?Fe@??gAgEFaA?CW?GQ?OMoKYIgE_@[?MU?IW?Ey@?HgBvQKkBg^e@eA?EU??S?P[?DQ_X?S?Iq@??Y?L]?R[wQh@eA?BS?MeBg^A_A?Po@?~@_B_XEO?WI?SUnKC[?Bc@gw@Ra@vj@d@]?TeA?`AaCoKJc@?Ce@gEKq@?[gA?Gk@gEFq@?Xw@?`A}AgEPm@?@q@?SaEg^Bc@?Ji@?Bo@?Ma@?[[?S[gbCIi@?@e@?j@_CnvAB_@?Ce@oKJyA?G{@?Ma@wQGi@?Ha@?^k@?Ts@?Kc@?S_@?Uk@?McAo}@Sw@?[aB~WQe@?a@U?_@iB??m@?Hk@?@q@_XC}@?o@wEooBm@{A~W?e@?L_A?Ac@gpAQw@??_A?HmB_q@AiA?M{@_XUeA?c@oCvj@?Y?H{A~p@Nq@??eA?PgAwcA@mA?Pu@gw@Ne@?HiA?EcA~WSyA?La@nd@P_A?@s@?C]?ScAgpAA_@?D{AwQLeB?Ei@?[kAnKOmA?Lu@fER}@?p@qAn}@TkA?HaBwQCcA?UiA?_@w@ozDIy@?C_A?I{@~bBOs@?Y_An}@m@aDnKMqA?a@qBo}@Eq@?HuBgENgAvQLoB~WFM?zAoA?`A]ohCt@I?j@??xHxBwkGdB\\wj@r@D?l@E?SiA?gA_CnKDyBf^Ks@?Qe@?s@aAgpAgAmA?Ya@?UkA?e@{GfEOo@wj@KY?QS?e@U?o@I?gABvQSG?US?I[?@}AoKKW?U]?KI?Sw@gbCCc@?HoDovALwAnoBGg@gw@a@}@?AQ?BY??i@_jAEW?]g@?[Q?uAoA_Xo@u@?sA{Dg^So@n}@c@eAwcA{@yA?mAgA?uAyBwnCCO?DQ?RU?lAq@nd@j@U?ZQ?LS~WH]?De@?HwD?H{@?Rq@g^fA_Co}@BW_jACS?g@q@?I[naD?_@?PwA_rGb@}@?L[?BWvQAY?}@aDgECY?LyB~bBEY?]oAwQIsAnd@@_B?NqAvQh@sAgw@h@u@g^NY?@[?AS?_@wAnKAU?Fa@?\\q@?dAs@g^d@s@f^HW?`@]?dDgAwuBL_@?H}A?r@eBwj@H]?TgDw|AFiG_XAeA?Ce@?G_@?aB_EoKOU?w@a@?OQftDIQ?QkA_cBKY?s@u@?EQ?BQgw@Xu@?H[?Ba@?EW?O]oKSS?OW?Uy@?PK?TW?XO?~@_@f^j@M_jAf@G?pA??V@fERL?\\h@nK`@Z?TH?X??t@SfiB~EgAvj@pFgBoKt@On}@hC_@wj@\\O?XS?P[?`AsCfw@NUgw@~@o@?fA{@nd@r@y@~p@l@{@?^M?^C?\\Fod@VPfiBn@fB?\\l@fiBXR?h@@gpAPJ?h@j@?|AnA?Xb@gEXr@?nApEfw@^~B~p@ZXw|ATtA~WN\\?LN?NH?P@?RC?ZO?r@g@wQPC?d@??`@F?RF?RRnaDfAvA?f@V~iAb@N?zC`@v|A\\Jod@PN?^p@?RJ?PA?lAa@fw@`@G?r@D?TH?NN?Vn@n}@DZ?@`@?IfEvcAQbBfw@CZ??`@?F`@?J\\v|Ab@`AwnChBnCvj@Pb@?J`A?@|Cwj@A~AgEGf@?Q`AvcAGn@??t@?HdBnoBTvBnaDLl@_kHRf@?t@pAnaDn@vA?d@n@?JTgEL`@~p@^hC~{Bd@~B?Tx@~bBBl@?A~@?Bz@fbCRlA?f@zBovAZ|B~p@D`@??^?G`A?Gj@~bBAd@?Hj@?Lb@?N`@nhC^h@?N^?ZdBv|AT~A_q@?f@?CXfpAM`@?Kp@?EbDnd@@`@?HH?L??LE~W\\g@?Ru@?Dg@?HOo}@HM?XS?RY?Ra@?r@_C~bBJu@?DO?\\o@gw@DQ?HmA?Jc@?\\}@_XJm@??k@?Gm@o}@Cc@?Dc@?DK?HG?d@EvnCTF?LT?Rv@?XzAnd@Fn@?@t@?IjA?Aj@?Bl@?DzB?Fd@?LF?NC?JIgbCFI?jA}C_XHE?N??Nu@?Na@?Zq@vQX_@wcAb@c@?`@W?`@G?`LYfiBfEU~iAf@??XD?XFv|A^P?VR?f@l@?lDdGnvAl@x@?f@\\~iAf@J?rDH~p@x@Df^H}@g^?c@?KoBo}@I]?",
      "ascend": 985,
      "descend": 999,
      "snapped_waypoints": "ac_nEt}dnUwvb@j|D_cNnvA"
    },
    "imageUrl":
        "https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/path-5+ff0000-1.0(ac_nEt%7DdnU%7CAe%40~AEH%7CAlB%7C%40XbA~%40rAh%40nA%60%40t%40%40pBGZgApAGrCD%60%40%7D%40oBm%40%7D%40GmA%5B%5B%5Ba%40%5Bp%40c%40%60A_%40%60%40G%5CHdAiAjFE%7CAPtA%5DbBv%40f%40%40T%5B%7C%40Oh%40aA%5BsAEoBc%40g%40e%40AaAAeDs%40mBu%40c%40k%40Iu%40k%40kBgA%7D%40U%7BBgDm%40qBq%40kD_%40mAuAkAYk%40Cu%40f%40u%40Nw%40EsBJ_AZi%40%5C%7DAEUk%40m%40Ie%40SHWJMOlAwBJg%40%5BGa%40IsBI%60AOz%40gAP%7D%40Q%7D%40Ew%40FuAXm%40jAq%40RkAC%7B%40SE%60%40yD%5EmAxCsCp%40MlDx%40%60AFvAgBhA_Et%40_E%7C%40qB%5CSdCo%40nA%7BAd%40%7DCr%40iF%5CcAFs%40d%40qHN_BRqCRwDAsA%5D%7DEi%40%7DAGmDBkCe%40wC%3FkAFmBByAW_%40y%40e%40Wm%40BaDq%40qDEi%40Vm%40IeALw%40%7C%40aBIyBNoBx%40oBk%40_%40%3F_Ax%40_AvAgEFiAg%40yB%3F%7DAzAuCR_BOeFNyAi%40%7D%40%5DeAl%40eD%3FeABuCUkAh%40mAHwAi%40kAa%40%7BBm%40gCaA_CHyAAoB%7DAsHLeBS%7BAHmDOeCy%40uEHuBNwBRuC%60%40%7BABmCE%7BBRsBWaBB%7BBFoCk%40yC%60%40sBfA%7DCDeDu%40aCMyBYoBgAaFo%40cEBgD%5CwDbB%7DAvBg%40dJxBxCb%40XoAaAyF%5DyA%7BBoCo%40mBu%40kI%5Dm%40uA_%40%7BAC_%40o%40IuBa%40g%40W%7BAVgGi%40eB%40k%40EaAy%40y%40eCeCgBkF_B_DcDaE%40a%40%60BgAfAg%40Vq%40N%7DE%5CmBjAwCk%40eAI%7B%40t%40uCPs%40_A%7BDHsCc%40iBGsDx%40eDx%40oA%3Fo%40a%40mBd%40sAjBgBj%40u%40rDgB%7C%40cE%5EeEDoIKeAqBuEgAs%40%5B%7DA_AoAAc%40b%40qAAy%40c%40q%40e%40qAf%40c%40xAo%40rAUhB%40p%40v%40v%40d%40nASpMoD~Do%40v%40c%40rAoDnAeAzBuBlAiA%7C%40BfAxBv%40%60Az%40LfCzBr%40vAnBpIp%40nB%5Cl%40%60%40Jn%40SdAk%40fAFf%40ZnBnB~Dp%40n%40Zr%40%7C%40~Ac%40tAAd%40X%5CjAGhFU~BFbAn%40~AzBrDL~EIfCYpBHzCb%40dDhAxBtAfCXv%40dAhGXfB%40zBz%40hE%60%40~CG%60BIpAVnAn%40jAj%40dCTfCQz%40QtEJj%40ZEp%40%7DANw%40b%40a%40f%40%7B%40~%40uDb%40_AN_Bh%40aBJyAKqAJo%40n%40Mb%40%5Cl%40rCHdBKvBHhDTl%40ZMrAgDXE%5EwAt%40qAdA%7B%40bMa%40nFUr%40Lv%40d%40tErHtAvAzETbAw%40KsC)/auto/1200x700?access_token=$kMapboxAccessToken",
    "routeOptions": {
      "profile": TransportationMode.gravel_cycling.value,
      "waypoints": []
    },
    "__v": 0
  },
  "likes": 1117,
};
