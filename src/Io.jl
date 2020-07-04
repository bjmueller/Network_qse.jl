"""
read in follwing files:
----------------
mass-frdm95.dat:
----------------
Ground state properties
based on the FRDM model
Format
------
Each record of the file contains:

   Z    : charge number
   A    : mass number
   El   : element symbol
   fl   : flag corresponding to 0 if no experimental data available
                                1 for a mass excess recommended by
                                  Audi&Wapstra (1995)
                                2 for a measured mass from
                                  Audi&Wapstra (1995)
   Mexp : experimental or recommended atomic mass excess in MeV of
          Audi&Wapstra (1995)
   Mth  : calculated FRDM atomic mass excess in MeV
   Emic : calculated FRDM microscopic energy in MeV
   beta2: calculated quadrupole deformation of the nuclear ground-state
   beta3: calculated octupole deformation of the nuclear ground-state
   beta4: calculated hexadecapole deformation of the nuclear ground-state
   beta6: calculated hexacontatetrapole deformation of the nuclear
          ground-state

The corresponding FORTRAN format is (2i4,1x,a2,1x,i1,3f10.3,4f8.3)

----------------
part_frdm.asc:
----------------
Each of the two files starts with 4 header lines briefly
summarizing the contents of the given columns. This is followed by
entries sorted by charge and mass number of the isotope. Each
table ends with the line "END OF TABLE".
Each entry consists of 5 lines:
1. Isotope (in standard notation);
2. Charge number of isotope, mass number of isotope, ground state
   spin of the isotope;
3-5. Partition functions normalized to the g.s. spin;
   Third line: Partition functions for the  temperatures (in 10^9 K):
   0.01, 0.15, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7;
       Fourth line:  Partition functions for the temperatures (in 10^9 K):
   0.8, 0.9, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5;
       Fifth line: Partition functions for the temperatures (in 10^9 K):
   4.0, 4.5, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0 .
Information for the next isotope starts after the last partition
function line.
"""

function read_part_frdm()
    table_string = open("$(@__DIR__)/../tables/part_frdm.asc", "r") do f
        readlines(f)
    end
    str_f = split.(table_string, "\n")
    deleteat!(str_f, [1:4;])
    data_string = str_f[2:5:length(str_f)]
    data_substring = map(x->split.(data_string[x], " "), 1:length(data_string))
    data_union = map(i->map(n->tryparse.(Float64,data_substring[i][n]), 1:length(data_substring[1])), 1:length(data_substring))
    data_union1 = map.(i-> filter!(k->k≠nothing,data_union[i][1]), [1:length(data_union);])
    data_res = map(x->identity.(data_union1[x]), [1:length(data_union1);])

    G_string = vcat(map(n-> str_f[3+5*n:5+5*n], 0:floor(Int, length(str_f)/5)-1)...)
    G_substring = vcat(map(x->split.(vcat(G_string[x]), " "), 1:length(G_string))...)
    G_union = map(n->tryparse.(Float64,G_substring[n]), 1:length(G_substring))
    G_union1 = map(y->filter!(x->x≠nothing,G_union[y]), 1:length(G_union))
    G_res = map(x->identity.(G_union1[x]), 1:length(G_union1))
    G_mod = map(n->G_res[1+3*n:3+3*n], 0:floor(Int, length(G_res)/3)-1)

    data_arr = permutedims(reshape(hcat(data_res...), (length(data_res[1]), length(data_res))))
    part_arr = reshape(hcat(G_mod...), (length(G_mod[1]), length(G_mod)))
    return data_arr, part_arr
end


function read_mass_frdm()
    table_string = open("$(@__DIR__)/../tables/mass-frdm95.dat", "r") do f
        readlines(f)
    end
    b = split.(table_string, "\n")
    deleteat!(b, [1:4;])
    k = vcat(map(x->split.(b[x], " "), 1:length(b))...)
    k1 = map(n->tryparse.(Float64,k[n]), 1:length(k))
    k2 = map.(i-> filter!(x->x≠nothing,k1[i]), 1:length(k1))
    k3 = map(x->identity.(k2[x]), 1:length(k2))
    k4 = map(i->k3[i][1:4], 1:length(k3))
    k4_arr = permutedims(reshape(hcat(k4...), (length(k4[1]), length(k4))))

    return k4_arr
end

d1 = read_mass_frdm()
d2, g = read_part_frdm()
m_charge_number = d1[:,1]
m_atomic_number = d1[:,2]
m_mass          = d1[:,3]
m_spin          = d1[:,4]
p_charge_number = d2[:,1]
p_atomic_number = d2[:,2]
m_zz_aa = d1[:,[1,2]]
p_zz_aa = d2[:,[1,2]]

function read_species()
    string = open("$(@__DIR__)/../tables/species.txt", "r") do f
        readlines(f)
    end
    number_species = parse(Int,string[1])
    splitting = split.(string, "\n")
    deleteat!(splitting, [1])
    k = vcat(map(x->split.(splitting[x], " "), [1:length(splitting);])...)
    k1 = map(n->tryparse.(Float64,k[n]), [1:length(k);])
    k2 = map.(i-> filter!(x->x≠nothing,k1[i]), [1:length(k1);])
    k3 = map(x->identity.(k2[x]), [1:length(k2);])
    k4 = permutedims(hcat(k3...))
    return k4, number_species
end

function extract_partition_function()
    fpart         = Array{Float64,2}[]
    atomic_number = Vector{Float64}()
    charge_number = Vector{Float64}()
    spin          = Vector{Float64}()
    mass          = Vector{Float64}()
    for i in eachindex(m_charge_number)
        for j in eachindex(p_charge_number)
            if (m_charge_number[i] == p_charge_number[j]) && (m_atomic_number[i] == p_atomic_number[j])
                push!(fpart, transpose(reshape(hcat(g[:,j]...), (length(g[:,j][1]), length(g[:,1])))))
                push!(atomic_number, m_atomic_number[i])
                push!(charge_number, m_charge_number[i])
                push!(spin, m_spin[i])
                push!(mass, m_mass[i])
            end
        end
    end
    return fpart, atomic_number, charge_number, spin, mass
end
