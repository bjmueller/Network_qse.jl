@testset "IO" begin
    g = Network_qse.extract_partition_function()
    @test isa(Network_qse.read_part_frdm()[1], Array{Float64,2})
    @test isa(Network_qse.read_species(), Tuple{Array{Float64,2},Int64})
    @test isa(Network_qse.read_mass_frdm()[4,:],Array{Float64,1})
    @test isa(g, Array{Network_qse.AtomicProperties,1})
    @test g[1].ω(1e9) == 2.0
    @test g[1].Z == 0
    @test g[1].A == 1
    @test g[1].M / (Network_qse.m_n*Network_qse.ergmev*Network_qse.c^2) < 1.02
    @test g[1].s == 0.5
    @test g[2].Z == 1
    @test g[2].A == 1
    @test g[2].M / (Network_qse.m_n*Network_qse.ergmev*Network_qse.c^2) < 1.02
    @test g[3].A == 2
    @test g[3].Z == 1
    @test g[5].M / (3.016029*Network_qse.m_u*Network_qse.ergmev*Network_qse.c^2) < 1.02
    @test g[5].Δ / 14.93 < 1.02
    @test g[5].Eb / 28.3 < 1.02
    @test g[393].name == "Fe56"
    @test g[393].M / (9.29e-23*Network_qse.ergmev*Network_qse.c^2) < 1.02
    @test g[393].Δ / (9.708e-5*Network_qse.ergmev*Network_qse.c^2) < 1.02
    @test (g[393].Eb/56) / 8.8 < 1.02

end
