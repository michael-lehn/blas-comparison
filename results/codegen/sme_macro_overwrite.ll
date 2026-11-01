declare void @llvm.aarch64.sme.zero(i32)
declare void @llvm.aarch64.sme.za.enable()
declare void @llvm.aarch64.sme.za.disable()
declare void @llvm.aarch64.sme.mopa.nxv2f64(i32, <vscale x 2 x i1>, <vscale x 2 x i1>, <vscale x 2 x double>, <vscale x 2 x double>)
declare void @llvm.aarch64.sme.ld1d.vert(<vscale x 2 x i1>, ptr, i32, i32)
declare void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1>, ptr, i32, i32)
declare void @llvm.aarch64.sme.ld1d.horiz(<vscale x 2 x i1>, ptr, i32, i32)
declare void @llvm.aarch64.sme.st1d.horiz(<vscale x 2 x i1>, ptr, i32, i32)
declare <vscale x 2 x i1> @llvm.aarch64.sve.whilelt.nxv2i1.i64(i64, i64)
declare <vscale x 2 x double> @llvm.aarch64.sve.ld1.nxv2f64(<vscale x 2 x i1>, ptr)
define void @entry(ptr %c, i64 %ldc, ptr %ap, ptr %bp, i64 %nip, i64 %njp, i64 %kce, i64 %aip, i64 %aks, i64 %bjp, i64 %bks, i64 %mrem, i64 %nrem) {
  call void @macro(ptr %c, i64 %ldc, ptr %ap, ptr %bp, i64 %nip, i64 %njp, i64 %kce, i64 %aip, i64 %aks, i64 %bjp, i64 %bks, i64 %mrem, i64 %nrem)
  ret void
}

define internal void @macro(ptr %c, i64 %ldc, ptr %ap, ptr %bp, i64 %nip, i64 %njp, i64 %kce, i64 %aip, i64 %aks, i64 %bjp, i64 %bks, i64 %mrem, i64 %nrem) #0 {
entry:
  call void @llvm.aarch64.sme.za.enable()
  %ldcnr = mul nsw i64 %ldc, 16
  %anyi = icmp sgt i64 %nip, 0
  %anyj = icmp sgt i64 %njp, 0
  %go = and i1 %anyi, %anyj
  br i1 %go, label %jploop, label %done

jploop:
  %jp = phi i64 [ 0, %entry ], [ %jpn, %jpend ]
  %jpn = add nuw nsw i64 %jp, 1
  %lastj = icmp eq i64 %jpn, %njp
  %cols = select i1 %lastj, i64 %nrem, i64 16
  %jrag = icmp ne i64 %cols, 16
  %bo = mul nsw i64 %jp, %bjp
  %bpj = getelementptr inbounds double, ptr %bp, i64 %bo
  %co = mul nsw i64 %jp, %ldcnr
  %cj = getelementptr inbounds double, ptr %c, i64 %co
  br label %iploop

iploop:
  %ip = phi i64 [ 0, %jploop ], [ %ipn, %ipend ]
  %ipn = add nuw nsw i64 %ip, 1
  %lasti = icmp eq i64 %ipn, %nip
  %rows = select i1 %lasti, i64 %mrem, i64 16
  %irag = icmp ne i64 %rows, 16
  %edge = or i1 %irag, %jrag
  %ao = mul nsw i64 %ip, %aip
  %api = getelementptr inbounds double, ptr %ap, i64 %ao
  %cio = mul nsw i64 %ip, 16
  %ci = getelementptr inbounds double, ptr %cj, i64 %cio
  br i1 %edge, label %tile_e, label %tile_f

tile_f:
  call void @llvm.aarch64.sme.zero(i32 255)
  %kposf = icmp sgt i64 %kce, 0
  br i1 %kposf, label %kloop_f, label %tstore_f

kloop_f:
  %kkf = phi i64 [ 0, %tile_f ], [ %kknf, %kloop_f ]
  %aofff = mul nsw i64 %kkf, %aks
  %bofff = mul nsw i64 %kkf, %bks
  %pa0f = getelementptr inbounds double, ptr %api, i64 %aofff
  %pa1f = getelementptr inbounds double, ptr %pa0f, i64 8
  %pb0f = getelementptr inbounds double, ptr %bpj, i64 %bofff
  %pb1f = getelementptr inbounds double, ptr %pb0f, i64 8
  %va0f = load <vscale x 2 x double>, ptr %pa0f, align 8
  %va1f = load <vscale x 2 x double>, ptr %pa1f, align 8
  %vb0f = load <vscale x 2 x double>, ptr %pb0f, align 8
  %vb1f = load <vscale x 2 x double>, ptr %pb1f, align 8
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 0, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va0f, <vscale x 2 x double> %vb0f)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 1, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va0f, <vscale x 2 x double> %vb1f)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 2, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va1f, <vscale x 2 x double> %vb0f)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 3, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va1f, <vscale x 2 x double> %vb1f)
  %kknf = add nuw nsw i64 %kkf, 1
  %kdonef = icmp eq i64 %kknf, %kce
  br i1 %kdonef, label %tstore_f, label %kloop_f

tstore_f:
  %sof1 = mul nsw i64 %ldc, 0
  %spf1 = getelementptr inbounds double, ptr %ci, i64 %sof1
  %sqf1 = getelementptr inbounds double, ptr %spf1, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf1, i32 0, i32 0)
  %sof2 = mul nsw i64 %ldc, 0
  %spf2 = getelementptr inbounds double, ptr %ci, i64 %sof2
  %sqf2 = getelementptr inbounds double, ptr %spf2, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf2, i32 2, i32 0)
  %sof3 = mul nsw i64 %ldc, 8
  %spf3 = getelementptr inbounds double, ptr %ci, i64 %sof3
  %sqf3 = getelementptr inbounds double, ptr %spf3, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf3, i32 1, i32 0)
  %sof4 = mul nsw i64 %ldc, 8
  %spf4 = getelementptr inbounds double, ptr %ci, i64 %sof4
  %sqf4 = getelementptr inbounds double, ptr %spf4, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf4, i32 3, i32 0)
  %sof5 = mul nsw i64 %ldc, 1
  %spf5 = getelementptr inbounds double, ptr %ci, i64 %sof5
  %sqf5 = getelementptr inbounds double, ptr %spf5, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf5, i32 0, i32 1)
  %sof6 = mul nsw i64 %ldc, 1
  %spf6 = getelementptr inbounds double, ptr %ci, i64 %sof6
  %sqf6 = getelementptr inbounds double, ptr %spf6, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf6, i32 2, i32 1)
  %sof7 = mul nsw i64 %ldc, 9
  %spf7 = getelementptr inbounds double, ptr %ci, i64 %sof7
  %sqf7 = getelementptr inbounds double, ptr %spf7, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf7, i32 1, i32 1)
  %sof8 = mul nsw i64 %ldc, 9
  %spf8 = getelementptr inbounds double, ptr %ci, i64 %sof8
  %sqf8 = getelementptr inbounds double, ptr %spf8, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf8, i32 3, i32 1)
  %sof9 = mul nsw i64 %ldc, 2
  %spf9 = getelementptr inbounds double, ptr %ci, i64 %sof9
  %sqf9 = getelementptr inbounds double, ptr %spf9, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf9, i32 0, i32 2)
  %sof10 = mul nsw i64 %ldc, 2
  %spf10 = getelementptr inbounds double, ptr %ci, i64 %sof10
  %sqf10 = getelementptr inbounds double, ptr %spf10, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf10, i32 2, i32 2)
  %sof11 = mul nsw i64 %ldc, 10
  %spf11 = getelementptr inbounds double, ptr %ci, i64 %sof11
  %sqf11 = getelementptr inbounds double, ptr %spf11, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf11, i32 1, i32 2)
  %sof12 = mul nsw i64 %ldc, 10
  %spf12 = getelementptr inbounds double, ptr %ci, i64 %sof12
  %sqf12 = getelementptr inbounds double, ptr %spf12, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf12, i32 3, i32 2)
  %sof13 = mul nsw i64 %ldc, 3
  %spf13 = getelementptr inbounds double, ptr %ci, i64 %sof13
  %sqf13 = getelementptr inbounds double, ptr %spf13, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf13, i32 0, i32 3)
  %sof14 = mul nsw i64 %ldc, 3
  %spf14 = getelementptr inbounds double, ptr %ci, i64 %sof14
  %sqf14 = getelementptr inbounds double, ptr %spf14, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf14, i32 2, i32 3)
  %sof15 = mul nsw i64 %ldc, 11
  %spf15 = getelementptr inbounds double, ptr %ci, i64 %sof15
  %sqf15 = getelementptr inbounds double, ptr %spf15, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf15, i32 1, i32 3)
  %sof16 = mul nsw i64 %ldc, 11
  %spf16 = getelementptr inbounds double, ptr %ci, i64 %sof16
  %sqf16 = getelementptr inbounds double, ptr %spf16, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf16, i32 3, i32 3)
  %sof17 = mul nsw i64 %ldc, 4
  %spf17 = getelementptr inbounds double, ptr %ci, i64 %sof17
  %sqf17 = getelementptr inbounds double, ptr %spf17, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf17, i32 0, i32 4)
  %sof18 = mul nsw i64 %ldc, 4
  %spf18 = getelementptr inbounds double, ptr %ci, i64 %sof18
  %sqf18 = getelementptr inbounds double, ptr %spf18, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf18, i32 2, i32 4)
  %sof19 = mul nsw i64 %ldc, 12
  %spf19 = getelementptr inbounds double, ptr %ci, i64 %sof19
  %sqf19 = getelementptr inbounds double, ptr %spf19, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf19, i32 1, i32 4)
  %sof20 = mul nsw i64 %ldc, 12
  %spf20 = getelementptr inbounds double, ptr %ci, i64 %sof20
  %sqf20 = getelementptr inbounds double, ptr %spf20, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf20, i32 3, i32 4)
  %sof21 = mul nsw i64 %ldc, 5
  %spf21 = getelementptr inbounds double, ptr %ci, i64 %sof21
  %sqf21 = getelementptr inbounds double, ptr %spf21, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf21, i32 0, i32 5)
  %sof22 = mul nsw i64 %ldc, 5
  %spf22 = getelementptr inbounds double, ptr %ci, i64 %sof22
  %sqf22 = getelementptr inbounds double, ptr %spf22, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf22, i32 2, i32 5)
  %sof23 = mul nsw i64 %ldc, 13
  %spf23 = getelementptr inbounds double, ptr %ci, i64 %sof23
  %sqf23 = getelementptr inbounds double, ptr %spf23, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf23, i32 1, i32 5)
  %sof24 = mul nsw i64 %ldc, 13
  %spf24 = getelementptr inbounds double, ptr %ci, i64 %sof24
  %sqf24 = getelementptr inbounds double, ptr %spf24, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf24, i32 3, i32 5)
  %sof25 = mul nsw i64 %ldc, 6
  %spf25 = getelementptr inbounds double, ptr %ci, i64 %sof25
  %sqf25 = getelementptr inbounds double, ptr %spf25, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf25, i32 0, i32 6)
  %sof26 = mul nsw i64 %ldc, 6
  %spf26 = getelementptr inbounds double, ptr %ci, i64 %sof26
  %sqf26 = getelementptr inbounds double, ptr %spf26, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf26, i32 2, i32 6)
  %sof27 = mul nsw i64 %ldc, 14
  %spf27 = getelementptr inbounds double, ptr %ci, i64 %sof27
  %sqf27 = getelementptr inbounds double, ptr %spf27, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf27, i32 1, i32 6)
  %sof28 = mul nsw i64 %ldc, 14
  %spf28 = getelementptr inbounds double, ptr %ci, i64 %sof28
  %sqf28 = getelementptr inbounds double, ptr %spf28, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf28, i32 3, i32 6)
  %sof29 = mul nsw i64 %ldc, 7
  %spf29 = getelementptr inbounds double, ptr %ci, i64 %sof29
  %sqf29 = getelementptr inbounds double, ptr %spf29, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf29, i32 0, i32 7)
  %sof30 = mul nsw i64 %ldc, 7
  %spf30 = getelementptr inbounds double, ptr %ci, i64 %sof30
  %sqf30 = getelementptr inbounds double, ptr %spf30, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf30, i32 2, i32 7)
  %sof31 = mul nsw i64 %ldc, 15
  %spf31 = getelementptr inbounds double, ptr %ci, i64 %sof31
  %sqf31 = getelementptr inbounds double, ptr %spf31, i64 0
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf31, i32 1, i32 7)
  %sof32 = mul nsw i64 %ldc, 15
  %spf32 = getelementptr inbounds double, ptr %ci, i64 %sof32
  %sqf32 = getelementptr inbounds double, ptr %spf32, i64 8
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> splat (i1 true), ptr %sqf32, i32 3, i32 7)
  br label %ipend

tile_e:
  %prlo = call <vscale x 2 x i1> @llvm.aarch64.sve.whilelt.nxv2i1.i64(i64 0, i64 %rows)
  %prhi = call <vscale x 2 x i1> @llvm.aarch64.sve.whilelt.nxv2i1.i64(i64 8, i64 %rows)
  call void @llvm.aarch64.sme.zero(i32 255)
  br label %kdis_e

kdis_e:
  %kpose = icmp sgt i64 %kce, 0
  br i1 %kpose, label %kloop_e, label %tstore_e

kloop_e:
  %kke = phi i64 [ 0, %kdis_e ], [ %kkne, %kloop_e ]
  %aoffe = mul nsw i64 %kke, %aks
  %boffe = mul nsw i64 %kke, %bks
  %pa0e = getelementptr inbounds double, ptr %api, i64 %aoffe
  %pa1e = getelementptr inbounds double, ptr %pa0e, i64 8
  %pb0e = getelementptr inbounds double, ptr %bpj, i64 %boffe
  %pb1e = getelementptr inbounds double, ptr %pb0e, i64 8
  %va0e = call <vscale x 2 x double> @llvm.aarch64.sve.ld1.nxv2f64(<vscale x 2 x i1> %prlo, ptr %pa0e)
  %va1e = call <vscale x 2 x double> @llvm.aarch64.sve.ld1.nxv2f64(<vscale x 2 x i1> %prhi, ptr %pa1e)
  %vb0e = load <vscale x 2 x double>, ptr %pb0e, align 8
  %vb1e = load <vscale x 2 x double>, ptr %pb1e, align 8
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 0, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va0e, <vscale x 2 x double> %vb0e)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 1, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va0e, <vscale x 2 x double> %vb1e)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 2, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va1e, <vscale x 2 x double> %vb0e)
  call void @llvm.aarch64.sme.mopa.nxv2f64(i32 3, <vscale x 2 x i1> splat (i1 true), <vscale x 2 x i1> splat (i1 true), <vscale x 2 x double> %va1e, <vscale x 2 x double> %vb1e)
  %kkne = add nuw nsw i64 %kke, 1
  %kdonee = icmp eq i64 %kkne, %kce
  br i1 %kdonee, label %tstore_e, label %kloop_e

tstore_e:
  %nlost = icmp slt i64 %cols, 8
  %clost = select i1 %nlost, i64 %cols, i64 8
  br label %stlo

stlo:
  %jstlo = phi i64 [ 0, %tstore_e ], [ %jstlon, %stlo ]
  %ostlo = mul nsw i64 %jstlo, %ldc
  %pstlo = getelementptr inbounds double, ptr %ci, i64 %ostlo
  %qstlo = getelementptr inbounds double, ptr %pstlo, i64 8
  %sstlo = trunc i64 %jstlo to i32
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> %prlo, ptr %pstlo, i32 0, i32 %sstlo)
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> %prhi, ptr %qstlo, i32 2, i32 %sstlo)
  %jstlon = add nuw nsw i64 %jstlo, 1
  %dstlo = icmp slt i64 %jstlon, %clost
  br i1 %dstlo, label %stlo, label %stmid

stmid:
  %anysthi = icmp sgt i64 %cols, 8
  br i1 %anysthi, label %sthi, label %ipend

sthi:
  %jsthi = phi i64 [ 8, %stmid ], [ %jsthin, %sthi ]
  %osthi = mul nsw i64 %jsthi, %ldc
  %psthi = getelementptr inbounds double, ptr %ci, i64 %osthi
  %qsthi = getelementptr inbounds double, ptr %psthi, i64 8
  %rsthi = sub nsw i64 %jsthi, 8
  %ssthi = trunc i64 %rsthi to i32
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> %prlo, ptr %psthi, i32 1, i32 %ssthi)
  call void @llvm.aarch64.sme.st1d.vert(<vscale x 2 x i1> %prhi, ptr %qsthi, i32 3, i32 %ssthi)
  %jsthin = add nuw nsw i64 %jsthi, 1
  %dsthi = icmp slt i64 %jsthin, %cols
  br i1 %dsthi, label %sthi, label %ipend

ipend:
  br i1 %lasti, label %jpend, label %iploop

jpend:
  br i1 %lastj, label %done, label %jploop

done:
  call void @llvm.aarch64.sme.za.disable()
  ret void
}
attributes #0 = { noinline "aarch64_inout_za" "aarch64_pstate_sm_body"
  "target-features"="+sme,+sme2,+sme-f64f64" }
