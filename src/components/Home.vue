<template>
  <div class="container container-top">
    <b-container>
      <h1>Plant list</h1>
      <b-list-group>
        <b-list-group-item v-for="plant in plants" v-bind:key="plant.id" class="text-left">
          <p>Id: {{ plant.id }}</p>
          <p>State: {{ states.find(p => p.value === plant.state).text }}</p>
          <p>Planted date: {{ plant.plantedDate }}</p>
          <p>Latitude: {{ plant.lat }}</p>
          <p>Longitude: {{ plant.long }}</p>
          <p>Nursery: {{ plant.nursery }}</p>
        </b-list-group-item>
      </b-list-group>
      <h1>Add plant</h1>
      <b-form @submit="onSubmit" @reset="onReset" v-if="show">
        <b-row>
          <b-col>
            <label for="id">
              ID
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-input
              id="id"
              v-model="form.id"
              type="number"
              placeholder="ID"
            />
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <label for="state">
              State
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-select
              id="state"
              v-model="form.state"
              :options="states"
            />
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <label for="date">
              Planted date
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-input
              id="date"
              v-model="form.date"
              type="date"
            />
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <label for="latitude">
              Latitude
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-input
              id="latitude"
              v-model="form.latitude"
              type="number"
              placeholder="56"
            />
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <label for="longitude">
              Longitude
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-input
              id="longitude"
              v-model="form.longitude"
              type="number"
              placeholder="3"
            />
          </b-col>
        </b-row>
        <b-row>
          <b-col>
            <label for="nursery">
              Nursery
            </label>
          </b-col>
          <b-col sm="9">
            <b-form-input
              id="nursery"
              v-model="form.nursery"
              type="text"
              placeholder="Nursery"
            />
          </b-col>
        </b-row>
        <b-button type="submit" variant="primary">Submit</b-button>
        <b-button type="reset" variant="secondary">Reset</b-button>
      </b-form>
    </b-container>
  </div>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'
import { mkdir } from 'fs';

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      form: {
        id: null,
        state: null,
        latitude: null,
        longitude: null,
        nursery: null,
        date: null
      },
      plants: [],
      states: [
        { value: 0, text: "Planted"},
        { value: 1, text: "Harvested"},
        { value: 2, text: "Weighted"}
      ],
      show: true
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]

      this.supplyContract = TruffleContract(Supply)
      
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

      this.supplyContract.deployed().then((contract) => {
        contract.getPlantCount().then((count) => {
           for (var i =0; i < count; i++)
            contract.getPlant(i).then((plant) => {
              this.addPlant(plant)
            })
        })
      })
    })

    console.log(this.plants)
  },
  methods: {
    addPlant: function(plant) {
      let p = {
        id: plant[0].toNumber(),
        state: plant[1].toNumber(),
        plantedDate: new Date(plant[2].toNumber() * 1000),
        lat: plant[3].toNumber(),
        long: plant[4].toNumber(),
        nursery: plant[5].toString()
      }

      this.plants.push(p)
    },
    onSubmit(evt) {
      evt.preventDefault()
      this.supplyContract.deployed().then((contract) => {
        contract.addPlant(this.form.id, this.form.state, (new Date(this.form.date).getTime()/1000), this.form.latitude, this.form.longitude, this.form.nursery)
      })
    },
    onReset(evt) {
      evt.preventDefault()
      // Reset our form values
      this.form.id = null
      this.form.state = null
      this.form.date = null
      this.form.latitude = null
      this.form.longitude = null
      this.form.nursery = null
      this.form.selectedState = null
      // Trick to reset/clear native browser form validation state
      this.show = false
      this.$nextTick(() => {
        this.show = true
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
.card-header{
  background-color: rgba(0, 0, 0, 0.000000001);
  border-bottom: 0px;
}
</style>
