import axios from 'axios';
import csrf from '@/utils/csrf';

export default axios.create({
  headers: Object.assign(
    csrf().headers,
    { 'X-Requested-With': 'XMLHttpRequest' }
  )
});
